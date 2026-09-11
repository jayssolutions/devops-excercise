variable "bucket_name" { type = string }

variable "force_destroy" {
  type        = bool
  default     = false
  description = "If true, allows deleting the S3 bucket even if it contains state files"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the S3 bucket"
}

