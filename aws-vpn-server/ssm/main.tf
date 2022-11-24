resource "aws_ssm_document" "ssm_doc" {
  name          = "${var.prefix}-vpn-ssm-document"
  document_type = "Command"
  tags          = var.common_tags
  content       = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Ansible Playbooks via SSM for Ubuntu 18.04 ARM, installs Ansible properly.",
    "parameters": {
    "SourceType": {
      "description": "(Optional) Specify the source type.",
      "type": "String",
      "allowedValues": [
      "GitHub",
      "S3"
      ]
    },
    "SourceInfo": {
      "description": "Specify 'path'. Important: If you specify S3, then the IAM instance profile on your managed instances must be configured with read access to Amazon S3.",
      "type": "StringMap",
      "displayType": "textarea",
      "default": {}
    },
    "PlaybookFile": {
      "type": "String",
      "description": "(Optional) The Playbook file to run (including relative path). If the main Playbook file is located in the ./automation directory, then specify automation/playbook.yml.",
      "default": "hello-world-playbook.yml",
      "allowedPattern": "[(a-z_A-Z0-9\\-)/]+(.yml|.yaml)$"
    },
    "ExtraVariables": {
      "type": "String",
      "description": "(Optional) Additional variables to pass to Ansible at runtime. Enter key/value pairs separated by a space. For example: color=red flavor=cherry",
      "default": "SSM=True",
      "displayType": "textarea",
      "allowedPattern": "^$|^\\w+\\=[^\\s|:();&]+(\\s\\w+\\=[^\\s|:();&]+)*$"
    },
    "Verbose": {
      "type": "String",
      "description": "(Optional) Set the verbosity level for logging Playbook executions. Specify -v for low verbosity, -vv or vvv for medium verbosity, and -vvvv for debug level.",
      "allowedValues": [
      "-v",
      "-vv",
      "-vvv",
      "-vvvv"
      ],
      "default": "-v"
    }
    },
    "mainSteps": [
    {
      "action": "aws:downloadContent",
      "name": "downloadContent",
      "inputs": {
      "SourceType": "{{ SourceType }}",
      "SourceInfo": "{{ SourceInfo }}"
      }
    },
    {
      "action": "aws:runShellScript",
      "name": "runShellScript",
      "inputs": {
      "runCommand": [
        "#!/bin/bash",
        "# Ensure ansible is installed",
        "yum update",
        "amazon-linux-extras install -y epel",
        "yum install -y openvpn nc",
        "sudo pip3 install --upgrade pip",
        "sudo pip3 install --upgrade ansible",
        "echo \"Running Ansible in `pwd`\"",
        "#this section locates files and unzips them",
        "for zip in $(find -iname '*.zip'); do",
        "  unzip -o $zip",
        "done",
        "PlaybookFile=\"{{PlaybookFile}}\"",
        "if [ ! -f  \"$${PlaybookFile}\" ] ; then",
        "   echo \"The specified Playbook file doesn't exist in the downloaded bundle. Please review the relative path and file name.\" >&2",
        "   exit 2",
        "fi",
        "ansible-playbook -i \"localhost,\" -c local -e \"{{ExtraVariables}}\" \"{{Verbose}}\" \"$${PlaybookFile}\""
      ]
      }
    }
    ]
  }
DOC
}
locals {
  ssm_extra_param = [
    "SSM=True",
    "aws_region=${var.aws_region}",
    "vpn_keys_server_secret_name=${var.vpn_keys_server_secret_name}",
    "vpn_server_dns=${var.vpn_server_dns}"
  ]
}

resource "aws_ssm_association" "ssm_assoc" {
  association_name = "${var.prefix}-vpn-ssm-association"
  name             = aws_ssm_document.ssm_doc.name
  targets {
    key    = "tag:vpn"
    values = ["True"]
  }
  output_location {
    s3_bucket_name = var.playbook_bucket_name
    s3_key_prefix  = "ssm"
  }
  parameters = {
    ExtraVariables = join(" ", local.ssm_extra_param)
    PlaybookFile   = "vpn.yaml"
    SourceInfo     = "{\"path\":\"https://s3.${var.aws_region}.amazonaws.com/${var.playbook_bucket_name}/playbook/\"}"
    SourceType     = "S3"
    Verbose        = "-v"
  }
  depends_on = [var.association_depends_on]
}
