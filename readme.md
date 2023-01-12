# Projet Linux Ansible Terraform - Eductive12

### Objectif du Projet

- Réaliser une infrastructure complète 
- Utilisation de terraform pour le déploiement de notre infrastructure
- Utilisation d'ansible pour la configuration de notre infrastrcture
- Avoir un WordPress avec une haute disponibilité 

# Installation

Commande pour avoir l'accès au fournisseur cloud  :

> source ~/openrc.sh

### Commandes Terraform

- Vérification syntaxe et erreurs des fichiers Terraform :
```
>tflint infra.tf
```

- Initialisation Terraform
```
terraform init
```

- Afficher le plan d'éxécution terraform
```
terraform plan
```

- Lancer l'execution du plan d'éxécution
```
terraform apply
```

- Vérification du déploiement 
```
terraform show
```

# Commandes Ansible

- Vérfification de la syntaxe d'un fichier
```
yamllint inventory.yml
```

- Déploiment de la configuration
```
ansible-playbook deploy-infra.yml 
```

# Fichiers crées et utilisés pour Terraform

- infra.tf
```
Fichier de configuration des instances
```

- inventory.tmpl 
```
Fichier inventory.yml pour Ansible
```

- providers.tf 
```
Fichier fournisseur de Cloud OVH
```

- variables.tf 
```
Fichier contenant les variables utilisées dans nos différents fichiers
```

# Fichiers et dossiers crées et utilisés pour Ansible

- deploy-infra.yml
```
Fichier de déploiement des configurations et services pour l'infrastructure
```

- inventory.yml
```
Contient les informations de nos instances en fonction de la configuration donnée dans inventory.tmpl
```

- haproxy.cfg
```
Fichier de configuration du service HAproxy
```

- index.html
```
Page HTML utilisé pour notre service web
```

- docker-compose.yml
```
Déploiement du conteneur contenant le service Wordpress
```

- ifconfig.io
```
Permet de lancer le service ipconfig.io
```

# Accès aux services via Instances
```
cat inventory.yml pour récupéer les IP
```

Sur la machine Frontend :
```
Port 80 - Accès backend page html web
Port 81 : Accès backend ifconfig.io
Port 82 : Accès backend WordPress
```