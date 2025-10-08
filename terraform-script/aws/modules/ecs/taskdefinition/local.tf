locals {
  SERVICE_CONFIG = {
    WITH_PORT = [
      for service in var.SERVICE_CONFIG.WITH_PORT : {
        SERVICE_NAME   = service.SERVICE_NAME
        PORT           = service.PORT
        health_check   = service.health_check
        
      }
    ]

    WITHOUT_PORT = var.SERVICE_CONFIG.WITHOUT_PORT

    NATS = var.SERVICE_CONFIG.NATS
  }
}

locals {
  image_url  = "ghcr.io/credebl"
}