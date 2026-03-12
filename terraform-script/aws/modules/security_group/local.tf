locals {
  EFS_PORT = 2049
}

locals {
  REDIS_CONFIG = {

    SERVICE_NAME   = "REDIS"
    PORT           = 6379
    file_system_id = ""

  }
}

locals {
  service_map = {
    for s in var.SERVICE_CONFIG.WITH_PORT :
    (s.SERVICE_NAME == "api-gateway" ? "platform" : s.SERVICE_NAME) => s.PORT
  }
}