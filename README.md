#### 20210746
# DEVOPS
test

TP 1

0) Création de mon environnement de travail 

-Cloner le projet avec git clone + lien https
-naviguer dans le répertoire du projet git

Ce n'était pas nécessaire mais j'ai choisi de créer un environnement virtuel dans lequel installer mes dépendances et docker.
  créer : ```python -m venv env```
  activer : ```source env/bin/activate```
  desactiver : ```deactivate```

Pour ne pas avoir à utiliser le mode administrateur sudo pour lancer une commande docker, je crée un groupe docker avec les permissions nécessaires auquel j'ajoute mon utilisateur :  
  sudo groupadd docker
  sudo usermod -aG docker ${USER}
Je teste les modifications en utilisant la commande docker : 
  systemctl start docker pour lancer les services docker puis
  docker run hello-world

Une fois ceci fait, j'écris une première version du code python en requêtant sur l'API openweather afin d'obtenir la météo. Je récupère une api_key sur le site d'openweather après avoir créé un compte. Je code les paramètres latitude, longitude en dur dans des variables environnement pour ne pas les stocker dans le code. (on notera que j'ai malencontreusement fait une faute dans le nommage de mon fichier et de mon image "weither" =( )
J'installe avec pip la dépendance requests que je note dans un fichier requirements.txt lequel sera ensuite exécuté à partir de mon dockerfile.

Je construis mon image docker en ajoutant une dépendance python minimale avec la version python:3.11-alpine3.17 dans le dockerfile avant de la pousser sur un repository sur mon compte dockerhub.

Création de l'image avec un tag local :
  docker build . -t weitherapp:0.0.1
Ajout d'un tag sur le repo distant : 
  docker tag weitherapp:0.0.1 ailogos/weitherapp:0.0.1
ou les 2 en un :
  docker build . -t weitherapp:0.0.1 -t ailogos/weitherapp:0.0.1

Pour pousser l'image, il faut s'assurer d'y avoir accès en se connectant avec ses identifiants avec les commandes suivantes : 
  docker login -u <username> -p <password> docker.io
on pousse ensuite l'image : 
  docker push ailogos/weitherapp:0.0.1
Enfin je lance la requête docker run et constate que les données sont bien récupérées.
docker run --env LAT="31.2504" --env LON="-99.2506" --env API_KEY="83a2af5dad9b498e4857f724163d713c" ailogos/weitherapp:0.0.1

Pour s'assurer que le code d'inférence (lié à la configurations et aux dépendances) écrit ne comporte pas de faille de sécurité connue, on utilise trivy.

Je récupère l'image avant de run trivy :
  docker pull aquasec/trivy
  docker run aquasec/trivy image ailogos/weitherapp:0.0.1

En l'occurence ici, j'ai dû mettre à jour le package de libcrypto3 qui comportait une faille moyenne en téléchargeant le fichier à jour recommandé.

Enfin avec hadolint on vérifie la structure de nos images écrites dans notre dockerfile qu'on corrige si besoin.
  docker pull hadolint/hadolint
  docker run --rm -i hadolint/hadolint < dockerfile
Dans mon cas j'ai dû rajouter l'option --no-cache-dir pour ne pas en stocker. 

TP2 : 

On configure un workflow Github Action de manière à ce qu'à chaque commit poussé sur notre répôt distant s'exécute des commandes voulues. Ces commandes se définissent dans un fichier .yaml .
Ici à chaque commit, notre image est construite et taggé comme vu précédemment. On désire également pousser automatiquement notre image sur le dockerhub, pour cela il faut avec les accès que l'on renseigne en renseignant nos identifiants utilisateur dans des secrets sur github. On peut y mettre un mot de passe ou une clé d'accès. 
Voir le fichier .yaml

Enfin on compte utiliser fastapi pour pouvoir exécuter des requêtes et récupérer les données météo avec une simple commande.
On installe donc fastapi et uvicorn, un webserver pour python.
pip install fastapi
pip install uvicorn

On lance le serveur : 
  uvicorn weither-api-call:app --reload
On peut également spéicifier l'hôte et le port que l'on souhaite
uvicorn weither-api-call:app --host 0.0.0.0 --port 8081

On teste la commande faisant appel au serveur avec :
  docker run --network host --env LAT="31.2504" --env LON="-99.2506" --env API_KEY=<api_key> ailogos/weitherapp:0.0.1
puis avec :
  curl "http://localhost:8081/?lat=5.902785&lon=102.754175&api_key=<api_key>"
et tout fonctionne correctement.

Pour finir on peut ajouter dans le fichier .yaml la vérification automatique de la structure de notre dockerfile en ajoutant ces lignes avnt la construction de l'image :
- name: Hadolint
  run: docker push ailogos/weitherapp:0.0.1

## TP 1

### Création de mon environnement de travail

-Cloner le projet avec git clone + lien https -naviguer dans le répertoire du projet git

Ce n'était pas nécessaire mais j'ai choisi de créer un environnement virtuel dans lequel installer mes dépendances et docker. créer : python -m venv env activer : source env/bin/activate desactiver : deactivate

Pour ne pas avoir à utiliser le mode administrateur sudo pour lancer une commande docker, je crée un groupe docker avec les permissions nécessaires auquel j'ajoute mon utilisateur :
sudo groupadd docker sudo usermod -aG docker ${USER} Je teste les modifications en utilisant la commande docker : systemctl start docker pour lancer les services docker puis docker run hello-world

Une fois ceci fait, j'écris une première version du code python en requêtant sur l'API openweather afin d'obtenir la météo. Je récupère une api_key sur le site d'openweather après avoir créé un compte. Je code les paramètres latitude, longitude en dur dans des variables environnement pour ne pas les stocker dans le code. (on notera que j'ai malencontreusement fait une faute dans le nommage de mon fichier et de mon image "weither" =( ) J'installe avec pip la dépendance requests que je note dans un fichier requirements.txt lequel sera ensuite exécuté à partir de mon dockerfile.

Je construis mon image docker en ajoutant une dépendance python minimale avec la version python:3.11-alpine3.17 dans le dockerfile avant de la pousser sur un repository sur mon compte dockerhub.

Création de l'image avec un tag local : 
```
docker build . -t weitherapp:0.0.1 
```
Ajout d'un tag sur le repo distant : 
```
docker tag weitherapp:0.0.1 ailogos/weitherapp:0.0.1 
```
ou les 2 en un : 
```
docker build . -t weitherapp:0.0.1 -t ailogos/weitherapp:0.0.1
```


Pour pousser l'image, il faut s'assurer d'y avoir accès en se connectant avec ses identifiants avec les commandes suivantes : 

    docker login -u -p docker.io 
on pousse ensuite l'image : 

    docker push ailogos/weitherapp:0.0.1 

Enfin je lance la requête docker run et constate que les données sont bien récupérées. 

    docker run --env LAT="31.2504" --env LON="-99.2506" --env API_KEY="83a2af5dad9b498e4857f724163d713c" ailogos/weitherapp:0.0.1

Pour s'assurer que le code d'inférence (lié à la configurations et aux dépendances) écrit ne comporte pas de faille de sécurité connue, on utilise **trivy**.

Je récupère l'image avant de run trivy : docker pull aquasec/trivy 
    
    docker run aquasec/trivy image ailogos/weitherapp:0.0.1

En l'occurence ici, j'ai dû mettre à jour le package de libcrypto3 qui comportait une faille moyenne en téléchargeant le fichier à jour recommandé.

Enfin avec **hadolint** on vérifie la structure de nos images écrites dans notre dockerfile qu'on corrige si besoin. docker pull hadolint/hadolint 
    
    docker run --rm -i hadolint/hadolint < dockerfile

Dans mon cas j'ai dû rajouter l'option --no-cache-dir pour ne pas en stocker.


## TP2 :

On configure un workflow Github Action de manière à ce qu'à chaque commit poussé sur notre répôt distant s'exécute des commandes voulues. Ces commandes se définissent dans un fichier .yaml . Ici à chaque commit, notre image est construite et taggé comme vu précédemment. On désire également pousser automatiquement notre image sur le dockerhub, pour cela il faut avec les accès que l'on renseigne en renseignant nos identifiants utilisateur dans des secrets sur github. On peut y mettre un mot de passe ou une clé d'accès. Voir le fichier .yaml

Enfin on compte utiliser fastapi pour pouvoir exécuter des requêtes et récupérer les données météo avec une simple commande. On installe donc fastapi et uvicorn, un webserver pour python. pip install fastapi pip install uvicorn

On lance le serveur : 

    uvicorn weither-api-call:app --reload

 On peut également spéicifier l'hôte et le port que l'on souhaite 
 
    uvicorn weither-api-call:app --host 0.0.0.0 --port 8081

On teste la commande faisant appel au serveur avec : 

    docker run --network host --env LAT="31.2504" --env LON="-99.2506" --env API_KEY=<api_key> ailogos/weitherapp:0.0.1

 puis avec : 
    

    curl "http://localhost:8081/?lat=5.902785&lon=102.754175&api_key=<api_key>"

 et tout fonctionne correctement.

Pour finir on peut ajouter dans le fichier .yaml la vérification automatique de la structure de notre dockerfile en ajoutant ces lignes avnt la construction de l'image :

    name: Hadolint run: docker push ailogos/weitherapp:0.0.1


    https://github.com/AILogos/20210746
    https://hub.docker.com/r/ailogos/weitherapp


TP3 : 
https://learn.microsoft.com/en-us/azure/container-instances/container-instances-github-action?tabs=userlevel
https://github.com/azure/aci-deploy

Build an image from a Dockerfile

Push the image to an Azure container registry

Deploy the container image to an Azure container instance


J'ai du modifié pour installer libcrypto3-3.0.8-r5 car libcrypto3-3.0.8-r4 n'est plus disponible, puis de nouveau la changer pour libcrypto3=3.1.1-r1
Après avoir réecrit un nouveau worflow pour le tp. Je me suis rendu compte qu'il fallait que je déactive le précédent.


curl "http://devops-20210746.westeurope.azurecontainer.io:8081/?lat=5.902785&lon=102.754175":8081

Les points forts de Github Action par rapport à l'interface utilisateur ou la CLI :

-Github actions permet de lancer automatiquement les commandes pour déployer notre code sans avoir à les taper manuellement sur la CLI.
-De plus la configuration de ces commandes est simplifiée d'autant que la structure des fichiers yaml est bien plus lisible.
-Il peut être programmé automatiquement après certaines actions comme un commit sur git.
-Il existe des actions pré-définies comme la connexion à docker ou Azure par exemple qui facilite le construction des workflows et permette un énorme gain de productivité

BONUS :

J'ai intégré Hadolint au workflow avec 
'- name: 'Checking the code with hadolint' 
          uses: hadolint/hadolint-action@v3.1.0
          with:
            dockerfile: dockerfile '
            Cela fonctionne mais relève une étrangement une "erreur" de multiple RUN que je n'arrive pas à résoudre donc je vais les commenter pour que le workflow puisse fonctionner correctement dans son intégralité.


# TP4 : 

Terraform est un environnement logiciel d'insfrastructure as code qui permet d'automatiser la construction de ressources ex : réseau, machines virtuelles, bases de données, etc.

Le but de ce tp est de créer automatiquement une vm disposant d'une adresse ip publique dans un réseau existant à l'aide de terraform. Il faudra être capable ensuite de se connecter à la vm avec SSH. 

## Installation de Terraform et de l'Azure CLI : 

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf install terraform


curl -L https://aka.ms/InstallAzureCli | bash
sudo dnf -y install azure-cli

Une fois l'installion effectuée on se connecte à Azure avec az login puis on lance la commande terraform init pour préparer l'espace de travail.

## Terraform

Dans le fichier main.tf on relie notre terraform avec Azure avec le provider en spécifiant notre abonnement.
Dans la partie network on crée la connexion entre notre machine virtuelle avec le réseau existant du TP en configurant une interface réseau.
On peut ensuite créer notre vm en renseignant entre autres l'inferface réseau précemment créée et on crée par la même occasion une clef SSH pour avoir accès à notre vm.
Enfin on spécifie en output de notre configuration (dans le fichier output.tf) la clef ssh qui nous permettra d'avoir accès à nos ressources.


On effectue ensuite les commandes suivantes : 

- terraform plan # si besoin pour afficher les changements sans les appliquer.
- terraform apply # pour mettre à jour la configuration
- terraform output # pour afficher les valeurs en sortie et la clef ssh
- terraform destroy pour supprimer les ressources
 
On lance ensuite la commande suivante pour se connecter en ssh. On note que l'adresse ip peut être trouvée via nos ressources Azure et que la clef privée est spécifiée dans la sortie output, ou dans le fichier txt.  

```ssh -i private_key.txt devops@10.3.1.29```


Problème je n'arrive pas à résoudre un connexion timed out en exécutant la connexion ssh.

Bonus : 

Pour vérifier que notre code terraform est bien formaté, on peut lancer la commande suivante 
terraform fmt -check
ou simplement terraform fmt pour appliquer le formatage automatique.
On crée un fichier vars.tf dans lequel on note les variables redondances

