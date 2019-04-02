# AWX
Installation and configuration AWX(Ansible Tower) running docker

## Table of contents

- [Getting started](#getting-started)
  - [Clone the repo](#clone-the-repo)
  - [AWX branding](#awx-branding)
  - [Prerequisites](#prerequisites)
  - [System Requirements](#system-requirements)
  - [AWX Tunables](#awx-tunables)
  - [Choose a deployment platform](#choose-a-deployment-platform)
  - [Official vs Building Images](#official-vs-building-images)
- [OpenShift](#openshift)
  - [Prerequisites](#prerequisites-1)
    - [Deploying to Minishift](#deploying-to-minishift)
  - [Pre-build steps](#pre-build-steps)
  - [PostgreSQL](#postgresql)
  - [Start the build](#start-the-build)
  - [Post build](#post-build)
  - [Accessing AWX](#accessing-awx)
- [Kubernetes](#kubernetes)
  - [Prerequisites](#prerequisites-2)
  - [Pre-build steps](#pre-build-steps-1)
  - [Configuring Helm](#configuring-helm)
  - [Start the build](#start-the-build-1)
  - [Accessing AWX](#accessing-awx-1)
  - [SSL Termination](#ssl-termination)
- [Docker Compose](#docker-compose)
  - [Prerequisites](#prerequisites-3)
  - [Pre-build steps](#pre-build-steps-2)
    - [Deploying to a remote host](#deploying-to-a-remote-host)
    - [Inventory variables](#inventory-variables)
      - [Docker registry](#docker-registry)
      - [PostgreSQL](#postgresql-1)
      - [Proxy settings](#proxy-settings)
  - [Start the build](#start-the-build-2)
  - [Post build](#post-build-1)
  - [Accessing AWX](#accessing-awx-2)

## Prerequisites

Before you can run a deployment, you'll need the following installed in your local environment:

- [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html) Requires Version 2.4+
- [Docker](https://docs.docker.com/engine/installation/)
- [docker-py](https://github.com/docker/docker-py) Python module
- [GNU Make](https://www.gnu.org/software/make/)
- [Git](https://git-scm.com/) Requires Version 1.8.4+
- [Node 8.x LTS version](https://nodejs.org/en/download/)
- [NPM 6.x LTS](https://docs.npmjs.com/)

### Installing prerequisites

```
```

### Checking prerequisites

```
```

## System Requirements

The system that runs the AWX service will need to satisfy the following requirements

- At leasts 4GB of memory
- At least 2 cpu cores
- At least 20GB of space
- Running Docker, Openshift, or Kubernetes
- If you choose to use an external PostgreSQL database, please note that the minimum version is 9.6+.

### Checking system requirements

```
```

## Local installation

### Clone the repo

```
git clone https://github.com/ansible/awx
```

