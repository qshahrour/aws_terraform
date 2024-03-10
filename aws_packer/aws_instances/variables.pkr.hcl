# ============================================


variable "communicator" {
  type    = string
  default = "ssh"
}

variable "locale" {
  type    = string
  default = "en_CA.UTF-8"
}

variable "ssh_agent_auth" {
  type    = string
  default = "false"
}

variable "ssh_clear_authorized_keys" {
  type    = string
  default = "false"
}

variable "ssh_disable_agent_forwarding" {
  type    = string
  default = "false"
}

variable "ssh_file_transfer_method" {
  type    = string
  default = "scp"
}

variable "ssh_fullname" {
  type    = string
  default = "Ghost Writer"
}

variable "ssh_handshake_attempts" {
  type    = string
  default = "100"
}

variable "ssh_keep_alive_interval" {
  type    = string
  default = "5s"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "ssh_pty" {
  type    = string
  default = "false"
}

variable "ssh_timeout" {
  type    = string
  default = "60m"
}

variable "ssh_username" {
  type    = string
  default = "ghost"
}

variable "start_retry_timeout" {
  type    = string
  default = "5m"
}

variable "ssh_file_transfer_method" {
  type    = string
  default = "scp"
}

variable "ssh_handshake_attempts" {
  type    = string
  default = "10"
}

variable "ssh_keep_alive_interval" {
  type    = string
  default = "5s"
}

variable "system_clock_in_utc" {
  type    = string
  default = "true"
}


variable "user_data_location" {
  type    = string
  default = "user-data"
}

variable "host_port" {
  type    = string
  default = "4444"
}

variable "host_port" {
  type    = string
  default = "22"
}

variable "http_port" {
  type    = string
  default = "9000"
}

variable "http_port" {
  type    = string
  default = "8000"
}
variable "timezone" {
  type    = string
  default = "UTC"
}

variable "ssh_clear_authorized_keys" {
  type    = string
  default = "false"
}

variable "cc" {
  type    = string
  default = ""
}

variable "ubuntu_version" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ssh_file_transfer_method" {
  type    = string
  default = "scp"
}






#ubuntu_version                  = ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*
#host_port                       = var.host_port
#http_content                    = { "/user-data" = templatefile(var.user_data_location, { var = var }) }
#ssh_agent_auth                  = var.ssh_agent_auth
#ssh_clear_authorized_keys       = var.ssh_clear_au#thorized_keys
#ssh_disable_agent_forwarding    = var.ssh_disable_agent_forwarding
#ssh_handshake_attempts          = var.ssh_handshake_attempts
#ssh_keep_alive_interval         = var.ssh_keep_alive_interval
#ssh_port                        = var.ssh_port#
#ssh_pty                         = var.ssh_pty
#ssh_timeout                     = var.ssh_timeout
#ssh_username                    = var.ssh_username
#ssh_file_transfer_method        = var.ssh_file_transfer_method
#ssh_handshake_attempts          = var.ssh_handshake_attempts
