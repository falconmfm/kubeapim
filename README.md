

Se inicializa gcloud con :

```
gcloud init 

```

La salida muestra:

```
Welcome! 

Pick configuration to use:
 [1] Re-initialize this configuration [terraform-rancher-nubentos2018] with new settings
 [2] Create a new configuration
 [3] Switch to and re-initialize existing configuration: [default]

Please enter your numeric choice:  2

Enter configuration name. Names start with a lower case letter and
contain only lower case letters a-z, digits 0-9, and hyphens '-':  manuelm-nubentos
Your current configuration has been set to: [manuelm-nubentos]

You can skip diagnostics next time by using the following flag:
  gcloud init --skip-diagnostics

Network diagnostic detects and fixes local network connection issues.
Checking network connection...done.
Reachability Check passed.
Network diagnostic (1/1 checks) passed.

Choose the account you would like to use to perform operations for
this configuration:
 [1] 
 [2] 
 [3] 
 [4] 
 [5] Log in with a new account
Please enter your numeric choice:  manuelm@falc0n.es
Please enter a value between 1 and 5:  5

Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&prompt=select_account&response_type=code&client_id=32555940559.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&access_type=offline


You are logged in as: [manuelm@falc0n.es].

Pick cloud project to use:
 [1] 
 [2] Create a new project
Please enter numeric choice or text value (must exactly match list
item):  2

Enter a Project ID. Note that a Project ID CANNOT be changed later.
Project IDs must be 6-30 characters (lowercase ASCII, digits, or
hyphens) in length and start with a lowercase letter. nubentos

```

Da una excepción al estar previamente creado el proyecto, por lo que lanzamos la línea de comandos con otro nombre

```
WARNING: Project creation failed: HttpError accessing <https://cloudresourcemanager.googleapis.com/v1/projects?alt=json>: response: <{'status': '409', 'content-length': '267', 'x-xss-protection': '1; mode=block', 'x-content-type-options': 'nosniff', 'transfer-encoding': 'chunked', 'vary': 'Origin, X-Origin, Referer', 'server': 'ESF', '-content-encoding': 'gzip', 'cache-control': 'private', 'date': 'Mon, 28 May 2018 18:02:09 GMT', 'x-frame-options': 'SAMEORIGIN', 'alt-svc': 'hq=":443"; ma=2592000; quic=51303433; quic=51303432; quic=51303431; quic=51303339; quic=51303335,quic=":443"; ma=2592000; v="43,42,41,39,35"', 'content-type': 'application/json; charset=UTF-8'}>, content <{
  "error": {
    "code": 409,
    "message": "Requested entity already exists",
    "status": "ALREADY_EXISTS",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.ResourceInfo",
        "resourceName": "projects/nubentos"
      }
    ]
  }
}
>
Please make sure to create the project [nubentos] using
    $ gcloud projects create nubentos
or change to another project using
    $ gcloud config set project <PROJECT ID>

```

Lo lanzamos con el nuevo nombre

```
gcloud project create nubentos0618
```

Comprobamos la cuenta de facturación y las organizaciones

```
gcloud organizations list
DISPLAY_NAME            ID  DIRECTORY_CUSTOMER_ID
falc0n.es     556490389464  C02qsqdci

gcloud beta billing accounts list 
ID                    NAME                      OPEN
01DC45-C5D4E8-BAE56D  Mi cuenta de facturación  True

```

Revisamos la lista de componentes asociadas a la cuenta : 

```
gcloud components list

```

Aseguramos que tenemos el componente de kubectl 

```
gcloud components install kubectl
```

Definimos las variables necesarias para gestionar el proyecto con Terraform:

Setamos el projecto por defecto:

```
gcloud config set project nubentos0618
```

Setamos la zona 

```
gcloud config set compute/zone europe-west1-a
```

Habilitar las API's de Kubernetes Engine

```
gcloud services enable container.googleapis.com
```

Habilitar la cuenta de facturación del proyecto nubento0618

Habilitar la API's de DNS

---

##Creamos el cluster de Kubernetes con GCLOUD :

Aseguramos que estamos con la cuenta de usuario 
```
gcloud config set account manuelm@falc0n.es
```

```
gcloud container clusters create nubentos
```

Obtenemos las credenciales con 

```
gcloud container clusters get-credentials nubentos
```

# Despliegue de una instancia de mysql

## Creamos un secreto para mantener las clave de acceso a mysql

```
kubectl create secret generic mysql-dev --from-literal=password=wso2ddbb
```

## Lanzamos el despliegue de la instancia de mysql con : 

```
kubectl create -f mysql_deployment.yml
```

Una vez levantada la bbdd debemos poblarlar con la creación de las bbdd para cada esquema. 

### Conectamos al pod y lanzamos 
```bash
mysql -u root -pwso2ddbb
```

A continuación vamos creando cada una de las bbdd's

```sql

create database regdb characterset latin1
create database apim 





## Desplegamos el API Manager

( esta parte podría lanzarse desde la Consola de GCP para ahorrar tiempo )

Configuramos el registro de Google Cloud , esto nos añade una serie de entradas en la configuración de docker de nuestro equipo

```
gcloud auth configure-docker
```
La salida muestra las entradas a añadir y solicita confirmación:

```
The following settings will be added to your Docker config file
located at [/Users/mangel.falcon/.docker/config.json]:
 {
  "credHelpers": {
    "gcr.io": "gcloud",
    "us.gcr.io": "gcloud",
    "eu.gcr.io": "gcloud",
    "asia.gcr.io": "gcloud",
    "staging-k8s.gcr.io": "gcloud"
  }
}

Do you want to continue (Y/n)?  Y

Docker configuration file updated.
```

De este modo la secuencia de despliegue es la siguientes:

-> docker build de la imagen con el tag de imagen local
-> docker tag para etiquetar la imagen con la ruta del registro de docker GCP con formato [HOSTNAME]/[PROJECT]/[IMAGE]:[TAG]
-> docker push 

Teniendo en cuenta que nuestro HOSTNAME es : eu.gcr.io

Con ello la secuencia de creación de la imagen de docker es :

Clonemos nuestro repositorio con los ficheros para crear la imagen de Docker.

```bash
git clone https://github.com/falconmfm/dockerapim.git
cd dockerapim
```

Contruimos la imagen 
```
docker build --tag eu.gcr.io/nubento0618/wso2amnub:1.5.1 .
```

Hacemos push de esta imagen
```
docker push eu.gcr.io/nubento0618/wso2amnub:2.1.0 
```

Clonamos el repositorio para el despliegue de recursos de Kubernetes

```
git clone https://github.com/falconmfm/nubeapim.git
```





---

##Creamos el cluster de kubernetes desde Terraform:

Tenemos que crear una cuenta de servicio y descargar el json 

Ahora asociamos la cluenta a gcloud con el comando:

```bash
export GOOGLE_PROJECT_ID=nubento0618
gcloud auth activate-service-account --key-file ./terraform-servaccount-nubentos0618.json --project $GOOGLE_PROJECT_ID
```

A continuación actualizamos los componentes

```
gcloud components update
```




