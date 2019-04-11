#!/usr/bin/env bash

###{{{ BEST PRACTICES

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace


__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

#arg1="${1:-}"

### BEST PRACTICES }}}

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
##Vars for launch job
VARS_TO_LAUNCH=$(echo "message=$1")

##Set survey file
SURVEY_TEXT='
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
}'

### VARS END }}}

###{{{ FUNCTIONS BEGIN

function etk-awx-cli-config() {

tower-cli config host $AWXHOST
tower-cli config username $AWXUSER
tower-cli config password $AWXPASS
tower-cli config verify_ssl false

}

##{{ CREATES

function etk-awx-cli-create-credential-git() {

  CRED_INPUTS="ssh_key_data: |"$'\n'"$(awk '{printf " %s\n", $0}' < ${SSH_KEY_FILE})"

  tower-cli credential create \
    --organization="$PROJECT_ORG" \
    --description="Credential-git for project ${PROJECT_ORG}-${PROJECT_NAME}" \
    --name="credential-git_${PROJECT_ORG}-${PROJECT_NAME}" \
    --credential-type="Source Control" \
    --inputs="$CRED_INPUTS" \
    --force-on-exists

}


function etk-awx-cli-create-credential-ssh() {

  CRED_INPUTS="ssh_key_data: |"$'\n'"$(awk '{printf " %s\n", $0}' < ${SSH_KEY_FILE})"

  tower-cli credential create \
    --organization="$PROJECT_ORG" \
    --description="Credential-git for project ${PROJECT_ORG}-${PROJECT_NAME}" \
    --name="credential-ssh_${PROJECT_ORG}-${PROJECT_NAME}" \
    --credential-type="Machine" \
    --inputs="$CRED_INPUTS" \
    --force-on-exists

}


function etk-awx-cli-create-project() {

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

## {{ CHECK PROJECT IS CREATED

function etk-awx-cli-check-project() {

  JSON_STATUS=$( tower-cli project status \
                   --format="json" \
                   --name="project-git_${PROJECT_ORG}-${PROJECT_NAME}" )

  echo "${JSON_STATUS}" | jq --raw-output '.status'

}


function etk-awx-cli-wait-for-project() {

  STATUS=$(etk-awx-cli-check-project)

  while [ "${STATUS}" != "successful" ]
  do

    STATUS=$(etk-awx-cli-check-project)

  done

}

## CHECK PROJECT IS CREATED }}


function etk-awx-cli-create-inventory() {

  tower-cli inventory create \
    --organization="$PROJECT_ORG" \
    --description="Inventory for ${PROJECT_ORG}-${PROJECT_NAME}" \
    --name="inventory_${PROJECT_ORG}-${PROJECT_NAME}" \
    --force-on-exists

}


function etk-awx-cli-create-inventory_source() {

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

  echo ${SURVEY_TEXT} > /tmp/survey_${PROJECT_ORG}-${PROJECT_NAME}.json

  tower-cli job_template modify \
    --name="job-template_${PROJECT_ORG}-${PROJECT_NAME}" \
    --survey-spec=@/tmp/survey_${PROJECT_ORG}-${PROJECT_NAME}.json \
    --survey-enabled=true

  rm /tmp/survey_${PROJECT_ORG}-${PROJECT_NAME}.json

}

## CREATES }}



##{{ DELETES

function etk-awx-cli-delete-credential-git() {

  tower-cli credential delete \
    --name="credential-git_${PROJECT_ORG}-${PROJECT_NAME}"
  
}


function etk-awx-cli-delete-credential-ssh() {

  tower-cli credential delete \
    --name="credential-ssh_${PROJECT_ORG}-${PROJECT_NAME}"

}


function etk-awx-cli-delete-project() {

  tower-cli project delete \
    --name="project-git_${PROJECT_ORG}-${PROJECT_NAME}"

}


function etk-awx-cli-delete-inventory() {

  tower-cli inventory delete \
    --name="inventory_${PROJECT_ORG}-${PROJECT_NAME}"

}


function etk-awx-cli-delete-job_template() {

  tower-cli job_template delete \
    --name="job-template_${PROJECT_ORG}-${PROJECT_NAME}"

}

## DELETES }}


function etk-awx-cli-create-env() {

  etk-awx-cli-config
  etk-awx-cli-create-credential-git
  etk-awx-cli-create-credential-ssh
  etk-awx-cli-create-project
  etk-awx-cli-create-inventory
  etk-awx-cli-create-inventory_source
  etk-awx-cli-wait-for-project  
  etk-awx-cli-create-job_template
  etk-awx-cli-create-job_template-survey

}


function etk-awx-cli-delete-env() {

  etk-awx-cli-delete-job_template
  etk-awx-cli-delete-inventory
  etk-awx-cli-delete-project
  etk-awx-cli-delete-credential-ssh
  etk-awx-cli-delete-credential-git

}


function etk-awx-cli-launch-job() {

  tower-cli job launch \
    --job-template=job-template_${PROJECT_ORG}-${PROJECT_NAME} \
    --extra-vars="${VARS_TO_LAUNCH}" \
    --monitor

}


### FUNCTIONS END }}}



###{{{ MAIN

if [ "$1" == "create" ]
then

  etk-awx-cli-create-env

elif [ "$1" == "launch" ]
then

  etk-awx-cli-launch-job $2

elif [ "$1" == "delete" ]
then

  etk-awx-cli-delete-env

fi

### MAIN }}}
