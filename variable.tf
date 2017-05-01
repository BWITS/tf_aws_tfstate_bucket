variable "source_region" {
  description = "s3 bucket's source region"
  default     = "ap-southeast-2"
}

variable "dest_region" {
  description = "s3 bucket's destination region"
  default     = "us-east-1"
}

variable "postfix" {
  description = "set postfix in bucket name to make it globally unique"
  default     = "terraform-state"
}
