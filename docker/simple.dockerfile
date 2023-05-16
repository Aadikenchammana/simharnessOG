ARG RAY_VERSION=2.4.0

# Deployment Stage
FROM rayproject/ray:${RAY_VERSION}-py39-cu116 as deploy

# Copy the needed code
WORKDIR /code/
COPY requirements.txt README.md LICENSE main.py ./
COPY conf/ conf/
COPY simharness2/ simharness2/

# Use below to fix the following error:
# E: The repository 'http://apt.kubernetes.io kubernetes-xenial Release' does not have a Release file.
RUN sudo su -c "echo 'deb http://packages.cloud.google.com/apt/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list"
# Use below to fix the following error:
# E: The repository 'https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64  Release' does not have a Release file.
RUN sudo su -c "echo 'deb [by-hash=no] http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /' > /etc/apt/sources.list.d/cuda.list"

# Install MITRE certs
RUN sudo apt-get update
RUN sudo apt-get install -y curl
RUN curl -ksSL https://gitlab.mitre.org/mitre-scripts/mitre-pki/raw/master/os_scripts/install_certs.sh | sudo sh
# Set the correct environment variables
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

RUN sudo apt-get install -y \
       build-essential \
       wget \
    && $HOME/anaconda3/bin/pip --no-cache-dir install -U pip \
    # Install requirements
    && $HOME/anaconda3/bin/pip --no-cache-dir install -U \
           -r requirements.txt \
    && sudo apt-get clean
