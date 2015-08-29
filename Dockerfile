# Usage:
# 
# docker run \
#   -e PROJECT=my-google-project \
#   -v /path/to/ssh_key:/ssl \
#   -v /var/run/docker.sock:/var/run/docker.sock \
#   --privileged ecor/gcloud components list
#

FROM gliderlabs/alpine:3.1
MAINTAINER Corey Butler <corey@coreybutler.com> (@goldglovecb)

# Set main environment variables
ENV PROJECT none
ENV dockertag 1.6.2

# Update the OS and install dependencies
RUN apk update && apk add wget bash python docker && rm -rf /var/cache/apk/*

# Install Docker
RUN wget https://get.docker.com/builds/Linux/x86_64/docker-latest -O /usr/bin/docker --no-check-certificate 
 
# Download and install the cloud sdk
RUN wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz --no-check-certificate \
    && tar zxvf google-cloud-sdk.tar.gz \
    && rm google-cloud-sdk.tar.gz \
    && ls -l \
    && ./google-cloud-sdk/install.sh --usage-reporting=true --path-update=true

# Add gcloud to the path
ENV PATH /google-cloud-sdk/bin:$PATH

# Configure gcloud for your project
RUN yes | gcloud components update
RUN yes | gcloud components update preview

# Prepare a directory for the launch script
WORKDIR /app
ADD . /app
RUN chmod +x /app/launch.sh

# Execute the launch script
ENTRYPOINT ["/app/launch.sh"]