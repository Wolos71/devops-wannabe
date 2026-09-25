variable "image_ocid" {
  description = "OCID of the Ubuntu image for E2.1.Micro"
  type        = string
}

resource "oci_core_instance" "main" {
  compartment_id      = var.compartment_ocid
  availability_domain = "cUfx:EU-FRANKFURT-1-AD-1"
  shape                = "VM.Standard.E2.1.Micro"
  display_name         = "terraform-instance"

  create_vnic_details {
    subnet_id        = oci_core_subnet.main.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/terraform_key.pub")
  }
}