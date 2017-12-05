# NO LONGER MAINTAINED

I'm now running my own private/on-premise registry and am no longer using GCR. If you are interested in maintaining this, let me know.

# GCLOUD Service Account Command (Google Cloud SDK)

This image is designed to execute [gcloud](https://cloud.google.com/sdk/) commands authenticated by a [Google service account](https://cloud.google.com/storage/docs/authentication#service_accounts) (using JSON), without having to install the commands on each Docker host.

This was inspired by the need to automate container deployments from a private [Google Container Registry](https://cloud.google.com/tools/container-registry/) on virtual machines hosted with SoftLayer, AWS, & Linode (probably works with others too, but I didn't have time to test every host).

The image is based on alpine linux, giving it a very small footprint compared to other containers that do something similar.

## Usage

```sh
docker run \
  -e PROJECT=my-google-project \
  -v /path/to/projectkey.json:/key/credentials.json \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged \
  --rm \
  ecor/gcloud components list
```

The command above authenticates with Google using your service account credentials against the project you
want to execute commands on. This is the equivalent of running:

```sh
gcloud auth activate-service-account \
  --key-file /path/to/projectkey.json \
  --project my-google-project \
  -q

gcloud components list
```

This will output something that looks similar to:

```sh
---------------------------------------------------------------------------------------------------------
|                                         Individual Components                                         |
|-------------------------------------------------------------------------------------------------------|
| Status        | Name                                          | ID                         |     Size |
|---------------+-----------------------------------------------+----------------------------+----------|
| Not Installed | App Engine Command Line Interface (Preview)   | app                        |   < 1 MB |
| Not Installed | App Engine SDK for Go                         | gae-go                     |          |
| Not Installed | App Engine SDK for Java                       | gae-java                   | 156.9 MB |
| Not Installed | App Engine SDK for Python and PHP             | gae-python                 |   < 1 MB |
| Not Installed | gcloud Alpha Commands                         | alpha                      |   < 1 MB |
| Not Installed | gcloud Beta Commands                          | beta                       |   < 1 MB |
| Not Installed | gcloud app Go Extensions (Linux, x86_64)      | app-engine-go-linux-x86_64 |  26.4 MB |
| Not Installed | gcloud app Java Extensions                    | app-engine-java            |  94.5 MB |
| Not Installed | gcloud app Python Extensions                  | app-engine-python          |   6.9 MB |
| Installed     | BigQuery Command Line Tool                    | bq                         |   < 1 MB |
| Installed     | Cloud DNS Admin Command Line Interface        | dns                        |   < 1 MB |
| Installed     | Cloud SDK Core Libraries                      | core                       |   1.9 MB |
| Installed     | Cloud SQL Admin Command Line Interface        | sql                        |   < 1 MB |
| Installed     | Cloud Storage Command Line Tool               | gsutil                     |   2.5 MB |
| Installed     | Compute Engine Command Line Interface         | compute                    |   < 1 MB |

To install new components or update existing ones, run:
 $ gcloud components update COMPONENT_ID
| Installed     | Compute Engine Command Line Tool (deprecated) | gcutil                     |   < 1 MB |
| Installed     | Default set of gcloud commands                | gcloud                     |   < 1 MB |
| Installed     | Developer Preview gcloud Commands             | preview                    |   < 1 MB |
---------------------------------------------------------------------------------------------------------
```

Notice te preview cloud commands are installed, because this image was really designed to use the Google Container Registry and Google Container Engine.

## Breakdown


#### PROJECT (Environment variable)

This is the name of the Google project, as found in the [developer console](https://console.developers.google.com) (Click on the project, then go to the Overview section).

#### /path/to/projectkey.json (volume)

To authenticate a service account, a key file (JSON) must be provided. Download the JSON file from the Google developer console (APIs & Auth > Credentials... assumes you've created a Client ID for a service account.). This key can be physically located anywhere on the server.

This image expects a volume to be mounted, mapping to a file called `/key/credentials.json`. So, if your key exists at `/path/to/my-service-account.json`, the volume can be mounted as `-v /path/to/my-service-account.json:/key/credentials.json`.

#### --privileged

This allows the command to execute as though it's on the phyiscal server.

### Using Docker with GCloud

This image was originally created in an effort to pull docker images onto a host machine from a private Google Container Registry. To do this, you must map the host Docker socket to the container. Just add `-v /var/run/docker.sock:/var/run/docker.sock` to the command to make this work.

## Automation

We use this image on our servers as part of an automatic deployment process, specifically to pull new images of our applications from our private Google Container Registry. To simplify this process, we usually create a script on the host server in the `/usr/bin` directory called `gcloud` to mimic the gcloud command. It looks like:

```sh
docker run \
  -e PROJECT=ecorproject \
  -v /keys/ecorprojectjwt.json:/key/credentials.json \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged \
  --rm \
  ecor/gcloud preview docker $*
```

Since the `/usr/bin` directory is already on the `PATH`, we can issue commands like `gcloud pull gcr.io/ecorproject/node-test`, which pulls our node.js test environment down from our private registry.
