variable "bucket" {
  type        = string
  default     = ""
  description = "Name of the bucket."
}
variable "acl" {
  type        = string
  default     = "private"
  description = "ACL"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to all the resources created by this module."
}
variable "folder_to_expiration_days" {
  type        = map(number)
  default     = {}
  description = "Mapping of folder name to the number of days before expiration."
}
variable "versioning" {
  type        = bool
  default     = false
  description = "Set to true to enable versioning."
}
variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
}
variable "kms_master_key_id" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
}
variable "bucket_policy" {
  type        = string
  default     = ""
  description = "JSON formatted string of the bucket policy."
}
variable "logging" {
  type        = map(string)
  default     = {}
  description = "Mapping of destination bucket to log path. If absent, no logs will be streamed."
}
variable "readonly_access" {
  type        = map(list(string))
  default     = {}
  description = "Mapping of s3 path to a list of IAM arns with read only access."
}
variable "readwrite_access" {
  type        = map(list(string))
  default     = {}
  description = "Mapping of s3 path to a list of IAM arns with read write access."
}
variable "whitelisted_ips" {
  type        = map(list(string))
  default     = {}
  description = "Mapping of s3 path to a list of IPs or CIDR blocks with read write access."
}
