/* 
  To import  
  Manage Security Group Rules: irida_galaxy (42fb7931-ef39-4581-8324-9bb180b8eacd)  
  Network irida_network_1 = ID - (780c6f5a-4676-4046-adae-3e6336b273dd)
  Name irida_subnet_1 = ID (215c1f86-f49f-408f-a3ae-99a8d1fa696d)
  Name router_1 = ID (e28b563a-2b7c-447f-a8ca-482345612ba0)

 */
resource "openstack_networking_secgroup_v2" "irida_galaxy" {
  name        = "irida_galaxy"
  description = "IRIDA - Galaxy access security group"
}

resource "openstack_compute_keypair_v2" "irida-gx-2005-keypair" {
  name       = "irida-gx-2005-keypair"  
  public_key = file("${var.ssh_pub_key_file}")
}

resource "openstack_networking_network_v2" "irida_network_1" {
  name           = "irida_network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "irida_subnet_1" {
  name            = "irida_subnet_1"
  network_id      = openstack_networking_network_v2.irida_network_1.id
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  dns_nameservers = ["192.168.2.75", "192.168.2.8"]
}

data "openstack_networking_network_v2" "public_network" {
  name = var.public_network
}

data "openstack_networking_network_v2" "ceph_network" {
  name = var.ceph_network
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router_1"
  admin_state_up      = "true"
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

resource "openstack_networking_floatingip_v2" "floatip_1" {
  pool = var.pool
}

resource "openstack_compute_instance_v2" "galaxy" {
  name            = "galaxy_v20_05_instance"
  image_id        = var.image_id
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.irida-gx-2005-keypair.name
  security_groups = ["default", "irida_galaxy"]
  user_data       = "#cloud-config\nhostname: ${var.fqdn} \nfqdn: ${var.fqdn}"
  
  metadata = { 
    ansible_groups = "galaxy"
  }

  network {
    uuid = openstack_networking_network_v2.irida_network_1.id
  }
}

resource "openstack_compute_floatingip_associate_v2" "galaxy_fip1" {
  floating_ip = openstack_networking_floatingip_v2.floatip_1.address
  instance_id = openstack_compute_instance_v2.galaxy.id
  fixed_ip    = openstack_compute_instance_v2.galaxy.network.0.fixed_ip_v4

  connection {
    host        = openstack_networking_floatingip_v2.floatip_1.address
    user        = var.ssh_user_name
    private_key = file("${var.ssh_priv_key_file}")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update"        
    ]
  }

}
