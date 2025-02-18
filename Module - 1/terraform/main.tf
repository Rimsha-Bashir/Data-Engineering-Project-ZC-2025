terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.20.0"
    }
  }
}

provider "google" {
  #credentials = file("gcp-terraform/keys/sa-creds.json")
  project     = var.project
  region      = var.region

}
resource "google_storage_bucket" "demo-bucket" {
  name          = var.gcs_bucketname
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = var.bq_dataset
}