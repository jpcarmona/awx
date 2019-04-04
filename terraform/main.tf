terraform {
  required_version = ">=0.11.13" //No se pueden usar variables en este bloque

  # Bucket 
  ## Creamos "Bucket S3" ("bucket-awx")
  ### https://s3.console.aws.amazon.com/s3/home?region=eu-west-1
  ### + Crear bucket
  ### -- Habilitamos versionado sólo
  # DynamoDB
  ## Creamos tabla en "DinamoDB" ("dynamodb-awx")
  ### https://eu-west-1.console.aws.amazon.com/dynamodb/home?region=eu-west-1
  ### Primary Key --> "LockID" (string)

  backend "s3" {
    bucket         = "bucket-awx"
    region         = "eu-west-1"
    key            = "states-tfstate" //Nombre inventado
    dynamodb_table = "dynamodb-awx"
    profile        = "default"
  }
}

data "aws_availability_zones" "az" {}

#data "template_file" "userdata" {
#  template = "${file("templates/userdata.tpl")}"
#  vars {
#    webserver = "apache2"
#  }
#}

provider "aws" {
  region  = "${var.region}"
  profile = "default"
}

resource "aws_key_pair" "awx" {
  public_key = "${file("${var.file-ssh-pubkey}")}"
  key_name   = "jp_awx"
}
