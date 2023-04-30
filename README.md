# 20210746
DEVOPS
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


pip install fastapi
pip install uvicorn

uvicorn weither-api-call:app --reload
ou
uvicorn weither-api-call:app --host 0.0.0.0 --port 8081

docker run --network host --env LAT="31.2504" --env LON="-99.2506" --env API_KEY=83a2af5dad9b498e4857f724163d713c ailogos/weitherapp:0.0.1

curl "http://localhost:8081/?lat=5.902785&lon=102.754175&api_key=83a2af5dad9b498e4857f724163d713c"

Dans .yaml
- name: Hadolint
  run: docker push ailogos/weitherapp:0.0.1
