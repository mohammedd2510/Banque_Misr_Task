data "external" "aws_creds" {
  program = ["bash", "-c", <<EOT
    echo '{ 
      "aws_access_key_id": "'$(aws configure get aws_access_key_id)'",
      "aws_secret_access_key": "'$(aws configure get aws_secret_access_key)'" 
    }'
EOT
  ]
}