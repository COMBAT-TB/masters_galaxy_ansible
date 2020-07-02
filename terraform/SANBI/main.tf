resource "openstack_networking_network_v2" "irida_v2005_galaxy_network" {
  name = "irida_v2005_galaxy_network"
}

resource "openstack_networking_subnet_v2" "irida_v2005_galaxy_network_sn_1" {
  name       = "irida_v2005_galaxy_network_sn_1"
  network_id = openstack_networking_network_v2.irida_v2005_galaxy_network.id
  cidr       = "192.168.50.0/24"
  allocation_pool {
    start = "192.168.50.50"
    end = "192.168.50.100"
  }
  dns_nameservers = ["192.168.2.75", "192.168.2.8"]
  ip_version = 4  
}

resource "openstack_networking_port_v2" "irida_v2005_galaxy_network_i_g_port" {
  name               = "irida_v2005_galaxy_network_i_g_port"
  network_id         = openstack_networking_network_v2.irida_v2005_galaxy_network.id
  security_group_ids = [openstack_compute_secgroup_v2.secgroup_galaxy.id]
  admin_state_up     = true
}

resource "openstack_compute_instance_v2" "irida-v20-05-galaxy" {
  name        = "irida-v20-05-galaxy"
  flavor_name = "m1.xlarge"
  key_pair    = "iridav2005gxkey"
  image_name  = "ubuntu-18.04-server"

  network {
    uuid = openstack_networking_network_v2.irida_v2005_galaxy_network.id
    port = openstack_networking_port_v2.irida_v2005_galaxy_network_i_g_port.id
  }

  network {
    uuid = openstack_networking_network_v2.irida_v2005_galaxy_network.id
    port = openstack_networking_port_v2.c-net_i_g_port.id
  }
 
}

output "i_g_floatingip_address" {
  value = openstack_compute_floatingip_associate_v2.i_g_floatingip_associate.floating_ip
}

resource "openstack_compute_keypair_v2" "iridav2005gxkey" {
  name = "iridav2005gxkey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "openstack_compute_floatingip_associate_v2" "i_g_floatingip_associate" {
  floating_ip = openstack_compute_floatingip_v2.i_g_floatingip.address
  instance_id = openstack_compute_instance_v2.irida-v20-05-galaxy.id
}

resource "openstack_blockstorage_volume_v2" "i_g_store" {
  name = "i_g_store"
  size = 160
}

resource "openstack_compute_volume_attach_v2" "i_g_store_attach" {
  instance_id = openstack_compute_instance_v2.irida-v20-05-galaxy.id
  volume_id = openstack_blockstorage_volume_v2.i_g_store.id
}

resource "openstack_compute_floatingip_v2" "i_g_floatingip" {
  pool = "public1"
}

resource "openstack_compute_secgroup_v2" "secgroup_galaxy" {
  name = "secgroup_galaxy"
  description = "galaxy server security group: SSH and HTTP/S"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}



resource "openstack_networking_network_v2" "ceph-net" {
  name = "ceph-net"
}

resource "openstack_networking_subnet_v2" "ceph-net_sn_1" {
  name = "ceph-net_sn_1"
  network_id = openstack_networking_network_v2.ceph-net.id
  cidr = "192.168.254.0/24"
  no_gateway = true
  enable_dhcp = false
  ip_version = 4
}

resource "openstack_networking_port_v2" "c-net_i_g_port" {
  name = "c-net_i_g_port"
  network_id = openstack_networking_network_v2.ceph-net.id
  security_group_ids = [openstack_compute_secgroup_v2.secgroup_galaxy.id]
  admin_state_up = true
}