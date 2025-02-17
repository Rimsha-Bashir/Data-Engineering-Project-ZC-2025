variable "project" {
  description = "GC-Terraform Project name"
  default     = "coral-velocity-451115-d9"
}

variable "location" {
  description = "Google Cloud provider location"
  default     = "EU"
}
variable "region" {
  description = "Google Cloud provider region"
  default     = "europe-west10"

}
variable "bq_dataset" {
  description = "BigQuery Dataset"
  default     = "demo_databse"

}
variable "gcs_storage_class" {
  description = "Google Cloud Bucket Storage class"
  default     = "STANDARD"
}
variable "gcs_bucketname" {
  description = "Demo Google Cloud Bucket name"
  default     = "coral-velocity-451115-d9-terra-bucket"
}