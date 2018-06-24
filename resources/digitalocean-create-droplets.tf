variable "digitalocean_token" {
  type = "string"
}

provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

# Create a new Web Droplet running centos in the FRA1 region
resource "digitalocean_droplet" "master" {
  image  = "centos-7-x64"
  name   = "k8s-master"
  region = "fra1"
  size   = "s-2vcpu-2gb"
}

# Create a new Web Droplet running centos in the FRA1 region
resource "digitalocean_droplet" "slave" {
  image  = "centos-7-x64"
  name   = "slave"
  region = "fra1"
  size   = "512mb"
}
