variable "namespace_name" {
  description = "Namespace where security policies apply"
  type        = string
}

variable "app_selector" {
  description = "Label selector for app pods"
  type        = map(string)
  default = {
    app = "resume-app"
  }
}

variable "mysql_selector" {
  description = "Label selector for mysql pods"
  type        = map(string)
  default = {
    app = "mysql"
  }
}
