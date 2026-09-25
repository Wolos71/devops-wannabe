resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "terraform-vcn"
  dns_label      = "tfvcn"
}

resource "oci_core_subnet" "main" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.main.id
  cidr_block = "10.0.1.0/24"
  display_name = "terraform-subnet"
  dns_label = "tfsubnet"
  route_table_id = oci_core_route_table.main.id
}


resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "terraform-igw"
  enabled        = true
}

resource "oci_core_route_table" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "terraform-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

