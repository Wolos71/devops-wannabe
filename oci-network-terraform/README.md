# OCI Network + Instance (Terraform)

Terraform configuration that builds a small, complete piece of Oracle Cloud infrastructure from scratch: a virtual network with internet access and a free-tier x86 VM inside it. Written as a learning project to replace manual console clicking and CLI OCID-hunting with declarative code.

## What it creates

- VCN (`10.0.0.0/16`)
- Subnet (`10.0.1.0/24`) attached to a custom route table
- Internet Gateway
- Route Table sending `0.0.0.0/0` through the Internet Gateway
- Compute instance (`VM.Standard.E2.1.Micro`, Ubuntu) with a public IP and SSH key access

Resources reference each other (`oci_core_vcn.main.id` and so on), so Terraform works out the creation order on its own.

## Requirements

- Terraform installed
- OCI CLI configured on the machine running Terraform (`~/.oci/config`, `DEFAULT` profile). The provider reuses these credentials.
- An SSH public key available at `~/.ssh/terraform_key.pub` on the machine running Terraform
- OCID of an Ubuntu image compatible with the `E2.1.Micro` shape (x86, so not the same image as for ARM shapes). It can be found with:
  `oci compute image list --compartment-id <ocid> --operating-system "Canonical Ubuntu" --shape "VM.Standard.E2.1.Micro"`

## Usage

1. Create `terraform.tfvars` (never committed, see below) with your values:

   | Variable | Description |
   |---|---|
   | `tenancy_ocid` | OCID of the OCI tenancy |
   | `compartment_ocid` | OCID of the compartment to create resources in (same as the tenancy if you don't use sub-compartments) |
   | `image_ocid` | OCID of the Ubuntu image |

2. Run:
```bash
   terraform init
   terraform plan
   terraform apply
```
3. Connect using the instance's public IP (visible in the `apply` output or via `terraform state show oci_core_instance.main`).
4. Clean up when done: `terraform destroy`

## Design notes

- **Secrets and state are not committed.** `*.tfvars`, `.terraform/` and `*.tfstate*` are in the repo-level `.gitignore`. State files can contain sensitive data, so they stay local. The provider lock file (`.terraform.lock.hcl`) is committed for reproducible provider versions.
- **Provider version is pinned** (`~> 6.0`) to avoid surprise breaking changes on a later `terraform init`.
- **SSH key is read with `file()`** instead of being pasted into the code, so the key stays a single source of truth.
- **Availability domain is hardcoded** (AD-1) for simplicity. If the shape is out of capacity there, change it manually.
- Uses `E2.1.Micro` on purpose: it is almost always available, so the apply/destroy cycle can be practiced without waiting for capacity (unlike ARM A1.Flex, see `oci-instance-hunter`).

## Possible next steps

- Configure the instance with Ansible (updates, firewall, SSH hardening, Docker)
- Create multiple instances from one resource block instead of copying it
- Move state to a remote backend