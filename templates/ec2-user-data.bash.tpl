#!/bin/bash

# Enable automated image pulls from AWS ECR
yum install -y jq amazon-ecr-credential-helper

# Get secrets from Secrets Manager
enc_password=`aws secretsmanager get-secret-value --secret-id ${secrets_id} --query SecretString --output text --region ${region} | jq -r .encryption_key`
license=`aws secretsmanager get-secret-value --secret-id ${license_secret_id} --query SecretString --output text --region ${region}`
pg_password=`aws secretsmanager get-secret-value --secret-id ${secrets_id} --query SecretString --output text --region ${region} | jq -r .db_password`
redis_password=`aws secretsmanager get-secret-value --secret-id ${secrets_id} --query SecretString --output text --region ${region} | jq -r .redis_auth_token`
replicated_pwd=`aws secretsmanager get-secret-value --secret-id ${secrets_id} --query SecretString --output text --region ${region} | jq -r .replicated_daemon_password`

# Dir for config files
mkdir -p /etc/terraform-enterprise

# RDS Certs
curl https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem > /etc/terraform-enterprise/rds-certs.pem
sed -i -z 's/\n/\\n/g' /etc/terraform-enterprise/rds-certs.pem

# License
echo $${license} | base64 -d > /etc/terraform-enterprise/license.rli

# Replicated configurations
cat > /etc/replicated.conf <<EOF
${replicated_settings}
EOF

# TFE configurations
cat > /etc/terraform-enterprise/tfe-settings.json <<EOF
${tfe_settings}
EOF

python <<EOF
import json
settings = json.load(open('/etc/terraform-enterprise/tfe-settings.json'))

settings.update({"ca_certs":{"value":"`cat /etc/terraform-enterprise/rds-certs.pem`"}})
settings.update({"enc_password":{"value":"$${enc_password}"}})
settings.update({"pg_password":{"value":"$${pg_password}"}})
settings.update({"redis_pass":{"value":"$${redis_password}"}})

json.dump(settings,open("/etc/ptfe-settings.json","w"))
EOF
rm /etc/terraform-enterprise/tfe-settings.json

# Run Installer
curl -o /etc/terraform-enterprise/install-tfe.sh https://install.terraform.io/ptfe/stable
bash /etc/terraform-enterprise/install-tfe.sh \
  no-proxy \
  disable-replicated-ui \
  private-address=`sed s/ip-//g /etc/hostname | sed s/.ec2.internal//g | sed s/-/./g` \
  public-address=`sed s/ip-//g /etc/hostname | sed s/.ec2.internal//g | sed s/-/./g`

# Add /usr/local/bin to root path so it can use `replicated` and `replicatedctl` cli tools
echo 'export PATH=$PATH:/usr/local/bin' >> /root/.bashrc

# Configure Docker so it can pull ECR images
[[ -d /root/.docker ]] || mkdir /root/.docker
echo '{"credsStore":"ecr-login"}' > /root/.docker/config.json

%{ if worker_image != "hashicorp/build-worker:now" ~}
# Pull custom worker image (It has to exist on the instance before runs are started)
docker pull ${worker_image}
%{ endif ~}

# Wait for happy healthchecks
while ! curl -ksfS --connect-timeout 5 https://`sed s/ip-//g /etc/hostname | sed s/.ec2.internal//g | sed s/-/./g`/_health_check; do
  sleep 5
done
