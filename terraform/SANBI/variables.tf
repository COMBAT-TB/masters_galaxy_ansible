variable "image_id" {
  default = "19d5293b-1356-4e2d-af3b-2b95d2ce3c7b"
}

variable "flavor" {
  default = "m1.xlarge"
}

variable "ssh_priv_key_file" {
  default = "~/.ssh/openstack/irida-gx-2005.pem"
}

variable "ssh_pub_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "pool" {
  default = "public1"
}

variable "fqdn" {
  default = "galaxy-v2005.sanbi.ac.za"
}

variable "public_network" {
  default = "public1"
}

variable "ceph_network" {
  default = "ceph-net"
}
