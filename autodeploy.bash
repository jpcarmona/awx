#!/bin/bash

###{{{ VARS BEGIN

## For all connections:
AWXUSER="admin"
AWXPASS="password"
AWXHOST="http://localhost"
## For naming resources:
PROJECT_NAME="juanpe"
PROJECT_ORG="Default"
## For projects:
PROJECT_URL="https://github.com/jpcarmona/awx.git"
##For credentials:
SSH_KEY_FILE="${HOME}/.ssh/${PROJECT_NAME}"

### VARS END }}}

###{{{ FUNCTIONS BEGIN

function etk-awx-cli-config() {
##Config tower-cli:

tower-cli config host $AWXHOST
tower-cli config username $AWXUSER
tower-cli config password $AWXPASS
tower-cli config verify_ssl false

}

function etk-awx-cli-create-credential-git() {
##Create credential type "git":
## -- Delete if exists with same name.

#CRED_INPUTS="{ \"ssh_key_data\": \"$(cat "$SSH_KEY_FILE" | tr '\n' ' ')\" }"

CRED_INPUTS="ssh_key_data: |
$(awk '{printf " %s\n", $0}' < $SSH_KEY_FILE)"

tower-cli credential create \
--organization="$PROJECT_ORG" \
--description="Credential-git for project ${PROJECT_ORG}-${PROJECT_NAME}" \
--name="credential-git_${PROJECT_ORG}-${PROJECT_NAME}" \
--credential-type="Source Control" \
--inputs="$CRED_INPUTS" \
--force-on-exists

}


function etk-awx-cli-create-credential-ssh() {
##Create credential type "ssh":
## -- Delete if exists with same name.

CRED_INPUTS="ssh_key_data: |
$(awk '{printf " %s\n", $0}' < $SSH_KEY_FILE)"

tower-cli credential create \
--organization="$PROJECT_ORG" \
--description="Credential-git for project ${PROJECT_ORG}-${PROJECT_NAME}" \
--name="credential-ssh_${PROJECT_ORG}-${PROJECT_NAME}" \
--credential-type="Machine" \
--inputs="$CRED_INPUTS" \
--force-on-exists

}


function etk-awx-cli-create-project() {
##Create project type "git":
## -- Delete if exists with same name.
## -- Update project when launching jobs

tower-cli project create \
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
--organization="$PROJECT_ORG" \
--description="Inventory for ${PROJECT_ORG}-${PROJECT_NAME}" \
--name="inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
--force-on-exists

}


function etk-awx-cli-create-inventory_source() {
##Create inventory_source :
## -- Delete if exists with same name.
## -- Update source when project updates (take several times to execute jobs)

tower-cli inventory_source create \
--description="Source for inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
--name="inventory-source_${PROJECT_ORG}-${PROJECT_NAME}" \
--inventory="inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
--source="scm" \
--source-project="project-git_${PROJECT_ORG}-${PROJECT_NAME}" \
--source-path="ansible/inventory.yml" \
--update-on-project-update=true \
--force-on-exists

}


function etk-awx-cli-create-job_template() {
##Create job_template :
## -- Delete if exists with same name.

tower-cli job_template create \
--job-type="run" \
--description="Job template for project ${PROJECT_ORG}-${PROJECT_NAME}" \
--name="job-template_${PROJECT_ORG}-${PROJECT_NAME}" \
--inventory="inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
--project="project-git_${PROJECT_ORG}-${PROJECT_NAME}" \
--playbook="ansible/playbook.yml" \
--credential="credential-ssh_${PROJECT_ORG}-${PROJECT_NAME}" \
--ask-variables-on-launch=true \
--force-on-exists \

}


function etk-awx-cli-create-job_template-survey() {
##Create a survey on a job_template :
## -- Delete if exists with same name.

cat << EOF > /tmp/survey_${PROJECT_ORG}-${PROJECT_NAME}.json
{
  "name": "",
  "description": "",
  "spec": [
    {
      "question_name": "Message",
      "question_description": "Write a message",
      "required": true,
      "type": "text",
      "variable": "message",
      "min": 0,
      "max": 1024,
      "default": "Hello World!",
      "choices": "",
      "new_question": true
    }
  ]
}
EOF

tower-cli job_template modify \
--name="job-template_${PROJECT_ORG}-${PROJECT_NAME}" \
--survey-spec=@/tmp/survey_${PROJECT_ORG}-${PROJECT_NAME}.json \
--survey-enabled=true

rm /tmp/survey_${PROJECT_ORG}-${PROJECT_NAME}.json

}


function etk-awx-cli-create-env() {
## Create full environment for a project
etk-awx-cli-config
etk-awx-cli-create-credential-git
etk-awx-cli-create-credential-ssh
etk-awx-cli-create-project
etk-awx-cli-create-inventory
etk-awx-cli-create-inventory_source
etk-awx-cli-create-job_template
etk-awx-cli-create-job_template-survey

}


### FUNCTIONS END }}}

###{{{ MAIN

etk-awx-cli-create-env
tower-cli job launch \
--job-template=job-template_${PROJECT_ORG}-${PROJECT_NAME} \
--extra-vars="$(echo "message=holajuanpe")" \
--monitor

### MAIN }}}
