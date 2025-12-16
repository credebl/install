resource "aws_s3_object" "api_gateway_env" {
  bucket  = var.env_file_bucket_id
  key     = "${var.environment}-API_GATEWAY.env"
  content = <<-EOT
    PLATFORM_PROFILE_MODE=${upper(var.environment)}
    API_GATEWAY_PROTOCOL=http
    API_GATEWAY_HOST=0.0.0.0
    API_GATEWAY_PORT=5000
    PLATFORM_NAME=${upper(var.project_name)}
    PROTOCOL=http
    TENANT_EMAIL_LOGO=credebl.jpg
    API_ENDPOINT=
    SOCKET_HOST=
    NATS_URL=
    REDIS_HOST=
    REDIS_PORT=${var.REDIS_CONFIG.PORT}
    SENDGRID_API_KEY=
    FRONT_END_URL= 
    AGENT_PROTOCOL=http
    CLUSTER_NAME=
    TASKDEFINITION_FAMILY=
    WALLET_STORAGE_HOST=${local.api_gateway_rds_proxy_credentials.endpoint}
    WALLET_STORAGE_PORT=${local.api_gateway_db_credentials.port}
    WALLET_STORAGE_USER=${local.api_gateway_db_credentials.username}
    WALLET_STORAGE_PASSWORD=${local.api_gateway_db_credentials.password}
    AWS_ACCOUNT_ID=${var.AWS_ACCOUNT_ID}
    PLATFORM_WALLET_NAME=platform-admin
    PLATFORM_WALLET_PASSWORD=
    PLATFORM_SEED=
    S3_BUCKET_ARN=${var.env_file_bucket_arn}
    
    CRYPTO_PRIVATE_KEY=
    PLATFORM_URL=
    AFJ_AGENT_SPIN_UP=/agent-provisioning/AFJ/scripts/fargate.sh
    AFJ_AGENT_ENDPOINT_PATH=/agent-provisioning/AFJ/endpoints/
    PLATFORM_ID=1
    AFJ_VERSION=public.ecr.aws/ayanworks-technologies/credebl:credo-controller
    PLATFORM_ADMIN_EMAIL=platform.admin@yopmail.com
    AFJ_AGENT_TOKEN_PATH=/agent-provisioning/AFJ/agent-config/token/
    AFJ_IMAGE_URL=public.ecr.aws/ayanworks-technologies/credebl:credo-controller
    INBOUND_TG_ARN=
    ADMIN_TG_ARN=
    AWS_PUBLIC_REGION=
    AGENT_API_KEY=

    FIDO_API_ENDPOINT=

    DATABASE_URL=postgres://${local.api_gateway_db_credentials.username}:${local.api_gateway_db_credentials.password}@${local.api_gateway_rds_proxy_credentials.endpoint}:${local.api_gateway_db_credentials.port}/platform
    POOL_DATABASE_URL=postgres://${local.api_gateway_db_credentials.username}:${local.api_gateway_db_credentials.password}@${local.api_gateway_rds_proxy_credentials.endpoint}:${local.api_gateway_db_credentials.port}/platform?pgbouncer=true
    PLATFORM_LOGO=CREDEBL_LOGO.svg
    POWERED_BY=Ayanworks Technologies Pvt Ltd
    PLATFORM_WEB_URL=
    POWERED_BY_URL=https://ayanworks.com
    UPLOAD_LOGO_HOST=
    API_GATEWAY_PROTOCOL_SECURE=http
    AWS_ORG_LOGO_BUCKET_NAME=${var.org_logo_bucket_id}
    OOB_BATCH_SIZE=10

    USER_NKEY_SEED=
    API_GATEWAY_NKEY_SEED=
    ORGANIZATION_NKEY_SEED=
    AGENT_PROVISIONING_NKEY_SEED=
    AGENT_SERVICE_NKEY_SEED=
    VERIFICATION_NKEY_SEED=
    LEDGER_NKEY_SEED=
    ISSUANCE_NKEY_SEED=
    CONNECTION_NKEY_SEED=
    CREDENTAILDEFINITION_NKEY_SEED=
    SCHEMA_NKEY_SEED=
    UTILITIES_NKEY_SEED=
    GEOLOCATION_NKEY_SEED=
    NOTIFICATION_NKEY_SEED=
    OIDC4VC_VERIFICATION_NKEY_SEED=
    OIDC4VC_ISSUANCE_NKEY_SEED=
    X509_NKEY_SEED=

    KEYCLOAK_DOMAIN=
    KEYCLOAK_ADMIN_URL=
    KEYCLOAK_MASTER_REALM=master
    KEYCLOAK_MANAGEMENT_CLIENT_ID=
    KEYCLOAK_MANAGEMENT_CLIENT_SECRET=
    KEYCLOAK_REALM=credebl_platform
    AWS_S3_STOREOBJECT_REGION=${var.region}
    AWS_S3_STOREOBJECT_BUCKET=${var.link_bucket_id}
    SHORTENED_URL_DOMAIN=https://s3.${var.region}.amazonaws.com/${var.link_bucket_id}
    DEEPLINK_DOMAIN=https://${var.link_bucket_id}?url=
    PUBLIC_PLATFORM_SUPPORT_EMAIL=support@ayanworks.com
    PUBLIC_LOCALHOST_URL=http://localhost:5000
    PUBLIC_DEV_API_URL=
    MOBILE_APP_NAME=ADEYA SSI App
    MOBILE_APP=ADEYA
    PLAY_STORE_DOWNLOAD_LINK=https://play.google.com/store/apps/details?id=id.credebl.adeya&pli=1
    IOS_DOWNLOAD_LINK=https://apps.apple.com/in/app/adeya-ssi-wallet/id6463845498
    MOBILE_APP_DOWNLOAD_URL=https://blockster.global/products/adeya
    SCHEMA_FILE_SERVER_URL=
    MAX_ORG_LIMIT=10
    SCHEMA_FILE_SERVER_TOKEN=
    GEO_LOCATION_MASTER_DATA_IMPORT_SCRIPT=/prisma/scripts/geo_location_data_import.sh
    UPDATE_CLIENT_CREDENTIAL_SCRIPT=/prisma/scripts/update_client_credential_data.sh
    ENABLE_CORS_IP_LIST=
    IS_ECOSYSTEM_ENABLE=
    PUBLIC_PLATFORM_LOGO=
    PUBLIC_DARK_MODE_LOGO=
    PLATFORM_POWERED_BY=

    SESSIONS_LIMIT=10
    APP_PROTOCOL=https

    CREDEBL_CLIENT_ALIAS=CREDEBL
    CREDEBL_DOMAIN=
    CREDEBL_KEYCLOAK_MANAGEMENT_CLIENT_ID=
    CREDEBL_KEYCLOAK_MANAGEMENT_CLIENT_SECRET=
    SUPPORTED_SSO_CLIENTS=CREDEBL

    ORGANIZATION=credebl
    CONTEXT=platform
    APP=api

    OTEL_SERVICE_NAME=CREDEBL-PLATFORM-SERVICES
    OTEL_SERVICE_VERSION=1.0.0
    OTEL_TRACES_OTLP_ENDPOINT=
    OTEL_LOGS_OTLP_ENDPOINT=
    OTEL_HEADERS_KEY=
    IS_ENABLE_OTEL=true
  EOT
}
