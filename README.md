# TODO

 - ssh/ ec2 key variable
 - tag variables/ attributes
 - license key variable
 - Examples

# Terraform Enterprise

A Terraform module that creates an AWS-based installation of Terraform Enterprise

## Releases
https://github.com/hashicorp/terraform-enterprise-release-notes

## Automated Installation Configurations
- *Replicated* - https://help.replicated.com/docs/native/customer-installations/automating/
- *Terraform Enterprise* - https://www.terraform.io/docs/enterprise/install/automating-the-installer.html

## Required Setup Steps

It is recommended that you first build this module with the min and max instance counts each set to 0, so you can finish the rest of the setup before turning them on. The bootstrap process for TFE involves touching external storage locations (PostgreSQL, Redis, S3), so those should be prepared before the bootstrap begins.

This module creates a password for the `administrator` and `terraform` users in the PostgreSQL database. You can retrieve the admin password via the output `db_admin_password`, and you can look for the terraform password in the Secrets Manager secret creatd by this module. Once the database is built, you will have to initialize the contents like so:

```sql
CREATE SCHEMA IF NOT EXISTS rails;
CREATE SCHEMA IF NOT EXISTS vault;
CREATE SCHEMA IF NOT EXISTS registry;

CREATE EXTENSION IF NOT EXISTS "hstore" WITH SCHEMA "rails";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "rails";
CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "registry";

CREATE USER terraform WITH PASSWORD '${password}';

ALTER DATABASE terraform OWNER TO terraform;
ALTER SCHEMA public OWNER TO terraform;
ALTER SCHEMA rails OWNER TO terraform;
ALTER SCHEMA vault OWNER TO terraform;
ALTER SCHEMA registry OWNER TO terraform;
```

Once this is done, you can scale the instances up (recommended 1-1 until configured; 2-2 long-term) to initialize the service. The _first_ time the service is initialized, you will need to make an admin user so you can configure the application. You can do that from one of the instances like so:

```bash
curl \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{"username":"admin","email":"${email}}","password":"${password}"}' \
  https://${server-url}/admin/initial-admin-user?token=`replicated admin --tty=0 retrieve-iact`
```

You can change the properties of this admin user later.
