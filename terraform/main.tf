variable "ad_index" {
  default = 0
}

#1. Get Availability Domain & Latest Ubuntu 22.04 ARM Image
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# 2. Networking (VCN, Internet Gateway, Route Table, Security List)
resource "oci_core_vcn" "k8s_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "k8s-portfolio-vcn"
  dns_label      = "k8svcn"
}

resource "oci_core_internet_gateway" "k8s_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "k8s-igw"
}

resource "oci_core_default_route_table" "k8s_rt" {
  manage_default_resource_id = oci_core_vcn.k8s_vcn.default_route_table_id
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.k8s_igw.id
  }
}

resource "oci_core_default_security_list" "k8s_sl" {
  manage_default_resource_id = oci_core_vcn.k8s_vcn.default_security_list_id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow all internal VCN traffic (node-to-node communication)
  ingress_security_rules {
    source   = "10.0.0.0/16"
    protocol = "all"
  }

  # Allow SSH (22), HTTP (80), HTTPS (443), and K8s API (6443)
  dynamic "ingress_security_rules" {
    for_each = [22, 80, 443, 6443]
    content {
      protocol = "6" # TCP
      source   = "0.0.0.0/0"
      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
    }
  }
}

resource "oci_core_subnet" "k8s_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.k8s_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "k8s-public-subnet"
  dns_label         = "k8ssubnet"
  security_list_ids = [oci_core_default_security_list.k8s_sl.id]
}

# 3. Compute Nodes in AD-2 (Index 0 = AD-1, Index 1 = AD-2, Index 2 = AD-3)
resource "oci_core_instance" "k8s_nodes" {
  count               = 2
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.ad_index].name
  compartment_id      = var.compartment_ocid
  display_name        = count.index == 0 ? "k8s-control-plane" : "k8s-worker-1"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k8s_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# 4. Output the Public IPs
output "node_public_ips" {
  value = {
    for idx, instance in oci_core_instance.k8s_nodes :
    instance.display_name => instance.public_ip
  }
}

