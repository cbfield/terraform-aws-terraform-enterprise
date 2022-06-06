{
  "aws_instance_profile": {
    "value": "1"
  },
  "capacity_concurrency": {
    "value": "${capacity_concurrency}"
  },
  "capacity_memory": {
    "value": "${capacity_memory}"
  },
  "custom_image_tag": {
    "value": "${custom_image_tag}"
  },
  "enable_active_active" : {
    "value": "1"
  },
  "force_tls": {
    "value": "true"
  },
  "hostname": {
    "value": "${hostname}"
  },
  "iact_subnet_list": {
    "value": "${iact_subnets}"
  },
  "installation_type": {
    "value": "production"
  },
  "pg_dbname": {
    "value": "terraform"
  },
  "pg_netloc": {
    "value": "${pg_netloc}"
  },
  "pg_user": {
    "value": "terraform"
  },
  "placement": {
    "value": "placement_s3"
  },
  "production_type": {
    "value": "external"
  },
  "redis_host" : {
    "value": "${redis_host}"
  },
  "redis_port" : {
    "value": "6379"
  },
  "redis_use_password_auth" : {
    "value": "1"
  },
  "redis_use_tls" : {
    "value": "1"
  },
  "restrict_worker_metadata_access": {
    "value": "0"
  },
  "s3_bucket": {
    "value": "${s3_bucket}"
  },
  "s3_region": {
    "value": "${region}"
  },
  "s3_sse": {
    "value": "aws:kms"
  },
  "s3_sse_kms_key_id": {
    "value": "${s3_kms_key}"
  },
  "tbw_image": {
    "value": "${tbw_image}"
  }
}
