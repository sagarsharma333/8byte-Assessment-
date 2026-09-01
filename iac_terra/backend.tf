terraform {
  backend "s3" {
    bucket = "8byte-terraform-statelocking"    #i need better nomenclature honstly
    key    = "8byte-state/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}