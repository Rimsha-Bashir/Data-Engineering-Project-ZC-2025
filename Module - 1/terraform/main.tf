terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.20.0"
    }
  }
}

provider "google" {
  # Configuration options
  # credentials = "./gcp-terraform/keys/sa-creds.json"
  project = "coral-velocity-451115-d9"
  region  = "us-central1"

}