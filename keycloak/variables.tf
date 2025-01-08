variable "realm" {
  type = string
  default = "credebl_realm"
}

variable "access_token_lifespan" {
  type = string
  default = "48h"
}

variable "sso_session_idle_timeout" {
  type = string
  default = "48h"
}

variable "realm_role" {
  type = string
  default = "holder"
}

variable "root_url" {
  type = string
  default = ""   # ADD ALB ENDPOINT
}

variable "redirect_url" {
  type = string
  default = ""    # ADD FRONTEND URL
}

variable "username" {
  type = string
  default = "admin"
}

variable "password" {
  type = string
  default = "admin"
}