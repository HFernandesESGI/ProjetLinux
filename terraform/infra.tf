resource "openstack_compute_keypair_v2" "Keypair_GRA11" {
  provider   = openstack.ovh
  name       = "sshkey_eductive12" 
  public_key = file("~/.ssh/id_rsa.pub")
  region     = var.region_GRA11
}

resource "openstack_compute_keypair_v2" "Keypair_SBG5" {
  provider   = openstack.ovh
  name       = "sshkey_eductive12"   
  public_key = file("~/.ssh/id_rsa.pub")
  region     = var.region_SBG5
}

resource "openstack_compute_instance_v2" "GRA11_Backend" {
  count       = var.compteur		     	             # Nombre d'instances dans cette région			
  name        = "${var.instance_name_gra}_${count.index+1}"  # Nom 
  provider    = openstack.ovh        			     # Fournisseur
  image_name  = var.image_name                               # Nom de l'image
  flavor_name = var.flavor_name                              # Nom du type d'instance
  region      = var.region_GRA11                             # Région

  # Plus délicat, mais cela va choisir la bonne clef de la bonne région
  key_pair    = openstack_compute_keypair_v2.Keypair_GRA11.name

# Composant réseau par défaut	
network {
	name = "Ext-Net"
  }
  network {
    	name = ovh_cloud_project_network_private.network.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}

resource "openstack_compute_instance_v2" "SBG5_Backend" {
  count       = var.compteur		     			# Nombre d'instances dans cette région			
  name        = "${var.instance_name_sbg}_${count.index+1}"  	# Nom de l'instance avec concaténation
  provider    = openstack.ovh        				# Fournisseur
  image_name  = var.image_name       				# Nom de l'image
  flavor_name = var.flavor_name      				# Type d'instance
  region      = var.region_SBG5      				# Région

  # Plus délicat, mais cela va choisir la bonne clef de la bonne région
  key_pair    = openstack_compute_keypair_v2.Keypair_SBG5.name

# Composant réseau par défaut	
network {
        name = "Ext-Net"
  }
  network {
    	name = ovh_cloud_project_network_private.network.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}

resource "openstack_compute_instance_v2" "Front" {
  count       = 1	  			# Nombre d'instance dans cette région			
  name        = "${var.instance_name_front}" 	# Nom de l'instance avec concaténation
  provider    = openstack.ovh        	     	# Fournisseur
  image_name  = var.image_name               	# Nom de l'image
  flavor_name = var.flavor_name              	# Type d'instance
  region      = var.region_GRA11             	# Région

  # Plus délicat, mais cela va choisir la bonne clef de la bonne région
  key_pair    = openstack_compute_keypair_v2.Keypair_GRA11.name

# Composant réseau par défaut	
network {
        name = "Ext-Net"
  }
  network {
    	name = ovh_cloud_project_network_private.network.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}

resource "ovh_cloud_project_database" "db_eductive12" {
  service_name = var.service_name
  description  = var.name_db
  engine       = "mysql"
  version      = "8"
  plan         = "essential"
  nodes {
    region = "GRA"
  }
  flavor = "db1-4"
}

resource "ovh_cloud_project_database_user" "db_eductive12" {
  service_name = ovh_cloud_project_database.db_eductive12.service_name
  engine       = "mysql"
  cluster_id   = ovh_cloud_project_database.db_eductive12.id
  name         = "hugo"
}

resource "ovh_cloud_project_database_database" "database" {
  service_name  = ovh_cloud_project_database.db_eductive12.service_name
  engine        = ovh_cloud_project_database.db_eductive12.engine
  cluster_id    = ovh_cloud_project_database.db_eductive12.id
  name          = "DB"
}

resource "ovh_cloud_project_database_ip_restriction" "db_eductive12" {
  service_name = ovh_cloud_project_database.db_eductive12.service_name
  engine       = ovh_cloud_project_database.db_eductive12.engine
  cluster_id   = ovh_cloud_project_database.db_eductive12.id
  ip           = "${openstack_compute_instance_v2.GRA11_Backend[2].access_ip_v4}/32"
}

resource "ovh_cloud_project_database_ip_restriction" "db_eductive012" {
  service_name = ovh_cloud_project_database.db_eductive12.service_name
  engine       = ovh_cloud_project_database.db_eductive12.engine
  cluster_id   = ovh_cloud_project_database.db_eductive12.id
  ip           = "${openstack_compute_instance_v2.SBG5_Backend[2].access_ip_v4}/32"
}

# Création d'un réseau privé
resource "ovh_cloud_project_network_private" "network" {
    service_name = var.service_name
    name         = "vrack_private_network_12"  # Nom du réseau
    regions      = var.regions
    provider     = ovh.ovh                     # Fournisseur
    vlan_id      = var.vlan_id                 # Identifiant VLAN pour le VRACK
}

resource "ovh_cloud_project_network_private_subnet" "subnet" {
    count        = length(var.regions)
    service_name = var.service_name
    network_id   = ovh_cloud_project_network_private.network.id
    start        = var.vlan_dhcp_start                          # Première IP de notre réseau
    end          = var.vlan_dhcp_end                            # Dernière IP de notre réseau
    network      = var.vlan_dhcp_network
    dhcp         = true                                         # Activation du DHCP
    region       = var.regions[count.index]
    provider     = ovh.ovh                                      # Fournisseur
    no_gateway   = true                                         # Pas de Gateway	
}

resource "local_file" "inventory" {
 filename = "../ansible/inventory.yml"
 content = templatefile("inventory.tmpl",
    {
      Instance1_GRA11 = openstack_compute_instance_v2.GRA11_Backend[0].access_ip_v4
      Instance2_GRA11 = openstack_compute_instance_v2.GRA11_Backend[1].access_ip_v4
      Instance3_GRA11 = openstack_compute_instance_v2.GRA11_Backend[2].access_ip_v4
      Instance1_SBG5 = openstack_compute_instance_v2.SBG5_Backend[0].access_ip_v4
      Instance2_SBG5 = openstack_compute_instance_v2.SBG5_Backend[1].access_ip_v4
      Instance3_SBG5 = openstack_compute_instance_v2.SBG5_Backend[2].access_ip_v4
      FrontPub_GRA11 = openstack_compute_instance_v2.Front[0].access_ip_v4
      IpPv = openstack_compute_instance_v2.Front[0].network[1].fixed_ip_v4
      passworddb = ovh_cloud_project_database_user.db_eductive12.password
      domaindb = ovh_cloud_project_database.db_eductive12.endpoints[0].domain
      portdb = ovh_cloud_project_database.db_eductive12.endpoints[0].port
    }
  )
}