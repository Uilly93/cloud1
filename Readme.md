# Cloud-1

## Présentation

Cloud-1 est un projet de déploiement automatisé d'une infrastructure WordPress sur AWS.

L'objectif est de pouvoir créer une ou plusieurs instances cloud, les configurer automatiquement puis déployer une application Wordpress conteneurisée sans intervention manuelle.

Le projet repose sur :

- Terraform
- AWS
- Ansible
- Docker
- Docker Compose
- Nginx
- WordPress
- MariaDB

---

## Architecture

```text
Terraform
    ↓
AWS EC2
    ↓
Ansible
    ↓
Docker Compose
    ├── Nginx
    ├── WordPress
    └── MariaDB
```

---

## Technologies utilisées

### AWS

Fournit l'infrastructure cloud :

- EC2
- Security Groups
- Adresses IP publiques
- Key Pair SSH

### Terraform

Terraform crée et détruit automatiquement les ressources AWS :

- Instances EC2
- Security Groups
- Clés SSH

Il garantit que l'infrastructure décrite dans le code correspond à celle déployée dans AWS.

### Ansible

Ansible configure automatiquement chaque machine après son déploiement :

- Installation des paquets nécessaires
- Installation de Docker
- Clonage du dépôt
- Construction de l'application

### Docker

Docker permet d'isoler les différents services dans des conteneurs indépendants.

### Docker Compose

Docker Compose orchestre l'ensemble des services :

- Nginx
- WordPress
- MariaDB

### Nginx

Nginx sert de point d'entrée HTTPS et reverse proxy.

### WordPress

Application web déployée automatiquement.

### MariaDB

Base de données utilisée par WordPress.

---

## Déroulement du déploiement

### 1. Authentification AWS

Le script s'authentifie auprès d'AWS :

```bash
aws login
```

Puis exporte les credentials pour Terraform.

---

### 2. Création de l'infrastructure

Terraform initialise puis crée les ressources :

```bash
terraform init
terraform apply
```

Terraform crée :

- Les instances EC2
- Le Security Group
- La Key Pair

---

### 3. Récupération des IP publiques

Terraform récupère automatiquement les IP des instances créées.

Ces IP servent à générer l'inventory Ansible.

---

### 4. Vérification de la disponibilité SSH

Ansible attend que les machines soient accessibles :

```bash
ansible cloud1 -m ping
```

---

### 5. Configuration des serveurs

Ansible :

- Met à jour le système
- Installe Git
- Installe Docker
- Installe Docker Compose
- Configure les utilisateurs

---

### 6. Déploiement de l'application

Ansible :

- Clone le dépôt Git
- Lance le build du projet
- Exécute Docker Compose

```bash
make
```

Le déploiement crée :

- Nginx
- WordPress
- MariaDB

---

## Sécurité

Les seuls ports exposés sont :

| Port | Usage |
|--------|--------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |

La base MariaDB n'est jamais accessible depuis Internet.

---

## Persistance des données

Les données WordPress et MariaDB sont stockées dans des volumes persistants.

Ainsi :

- les utilisateurs sont conservés ;
- les articles sont conservés ;
- les médias uploadés sont conservés ;
- un redémarrage de la machine ne provoque aucune perte de données.

---

## Redémarrage automatique

Docker est configuré pour démarrer automatiquement au lancement du serveur.

Les conteneurs utilisent :

```yaml
restart: always
```

Ainsi après un reboot :

```text
EC2
 ↓
Docker
 ↓
MariaDB
 ↓
WordPress
 ↓
Nginx
```

L'application est à nouveau accessible sans intervention.

---

## Déploiement multi-serveurs

L'architecture permet de déployer le même service sur plusieurs instances EC2 simultanément.

Terraform peut créer plusieurs machines.

Ansible génère automatiquement un inventory contenant toutes les IP :

```ini
[cloud1]
IP1
IP2
IP3
```

Le même playbook est alors exécuté en parallèle sur chaque serveur.

---

## Accès à l'application

Une fois le déploiement terminé :

```text
https://IP_PUBLIQUE
```

Connexion à WordPress :

```text
https://IP_PUBLIQUE/wp-login.php
```

Administration WordPress :

```text
https://IP_PUBLIQUE/wp-admin
```

---

## Résultat

Le projet fournit une chaîne de déploiement entièrement automatisée :

```text
Terraform
    ↓
AWS
    ↓
Ansible
    ↓
Docker
    ↓
WordPress
```

permettant de déployer rapidement une infrastructure fonctionnelle 
