#!/bin/bash

###{{{ VARS BEGIN

AWXUSER="admin"
AWXPASS="password"
AWXHOST="localhost"
PROJECT_NAME="juanpe"
PROJECT_ORG="Default"
PROJECT_URL="https://github.com/jpcarmona/awx.git"
SSH_KEY_FILE="${HOME}/.ssh/${PROJECT_NAME}"

### VARS END }}}

###{{{ FUNCTIONS BEGIN

function etk-awx-cli-create-credential() {
##Create credential type "git":
## -- Delete if exists with same name.

#CRED_INPUTS="{ \"ssh_key_data\": \"$(cat "$SSH_KEY_FILE" | tr '\n' ' ')\" }"

CRED_INPUTS="ssh_key_data: |
$(awk '{printf " %s\n", $0}' < ~/.ssh/id_rsa)"

tower-cli credential create \
-u="$AWXUSER" \
-p="$AWXPASS" \
-h="$AWXHOST" \
--organization="$PROJECT_ORG" \
--description="Credential-git for project ${PROJECT_ORG}-${PROJECT_NAME}" \
--name="credential-git_${PROJECT_ORG}-${PROJECT_NAME}" \
--credential-type="Source Control" \
--inputs="$CRED_INPUTS" \
--force-on-exists

}


function etk-awx-cli-create-project() {
##Create project type "git":
## -- Delete if exists with same name.
## -- Update project when launching jobs

tower-cli project create \
-u="$AWXUSER" \
-p="$AWXPASS" \
-h="$AWXHOST" \
--organization="$PROJECT_ORG" \
--description="Project-git for ${PROJECT_ORG}-${PROJECT_NAME}" \
--name="project-git_${PROJECT_ORG}-${PROJECT_NAME}" \
--scm-type="git" \
--scm-url="$PROJECT_URL" \
--scm-branch="master" \
--scm-credential="credential-git_${PROJECT_ORG}-${PROJECT_NAME}" \
--scm-update-on-launch=true --force-on-exists

}


function etk-awx-cli-create-inventory() {
##Create inventory :
## -- Delete if exists with same name.

tower-cli inventory create \
-u="$AWXUSER" \
-p="$AWXPASS" \
-h="$AWXHOST" \
--organization="$PROJECT_ORG" \
--description="Inventory for ${PROJECT_ORG}-${PROJECT_NAME}" \
--name="inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
--force-on-exists

}


function etk-awx-cli-create-inventory-source() {
##Create inventory_source :
## -- Delete if exists with same name.
## -- Update source when project updates

tower-cli inventory_source create \
-u="$AWXUSER" \
-p="$AWXPASS" \
-h="$AWXHOST" \
--description="Source for inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
--name="inventory-source_${PROJECT_ORG}-${PROJECT_NAME}" \
--inventory="inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
--source="scm" \
--source-project="project-git_${PROJECT_ORG}-${PROJECT_NAME}" \
--source-path="ansible/inventory.yml" \
--update-on-project-update=true --force-on-exists

}

### FUNCTIONS END }}}