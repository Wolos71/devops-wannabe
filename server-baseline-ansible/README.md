# server-baseline-ansible

Ansible playbooks that turn a bare Ubuntu instance (from `oci-network-terraform`) into a hardened, ready-to-use server: a dedicated non-root user with SSH-key access, sudo, and a locked-down SSH daemon.

## What it does

Two playbooks, run in order, each connecting as a different user:

1. **`bootstrap.yml`** — connects as the image's default `ubuntu` user (NOPASSWD sudo from cloud-init). Creates the `wolos` user, installs their SSH public key, and grants sudo (password-protected, hash stored in an Ansible Vault file).
2. **`hardening.yml`** — connects as `wolos`. Restricts SSH login to `wolos` only (`AllowUsers`), disables password authentication and root login, restarts `sshd` only if something actually changed (via a handler), and removes the `ubuntu` NOPASSWD sudoers file left by cloud-init.

## Requirements

- Ansible (ansible-core; version notes below)
- `ansible.posix` collection (used by `authorized_key`) — install with `ansible-galaxy collection install ansible.posix`. Not yet pinned in a `requirements.yml`; a possible next step.
- SSH access to the target as `ubuntu` (first run only)

## Usage

1. Copy `inventory.yml.example` to `inventory.yml` and fill in the real IP. Keep `ansible_user: ubuntu` for the first run.
2. Create `vault/pass.yml` (user's password hash, `openssl passwd -6`) and `vault/userpass.yml` (the same password in plain text, needed for `become` at sudo time) with `ansible-vault create <path>`. Both are referenced via `vars_files` in the relevant playbook.
3. Run bootstrap:
```bash
   ansible-playbook -i inventory.yml bootstrap.yml --ask-vault-pass
```
4. Manually verify `ssh wolos@<ip>` and `sudo -v` work before continuing — hardening removes the fallback account.
5. Switch `ansible_user` in `inventory.yml` to `wolos`.
6. Keep a spare SSH session open, then run:
```bash
   ansible-playbook -i inventory.yml hardening.yml
```
7. In a **new** terminal, confirm `ssh wolos@<ip>` still works and `ssh ubuntu@<ip>` is refused before closing the spare session.

## Design notes

- **Secrets are not committed.** `inventory.yml` (real IP) and anything under `vault/` that isn't vault-encrypted are gitignored. Vault files themselves are safe to commit — verify with `head -1 <file>`, expecting `$ANSIBLE_VAULT;1.1;AES256`.
- **`wolos`'s sudo is NOPASSWD**, not password-protected, despite a password hash existing in Vault. This was a deliberate fallback after extensive debugging: password-based `become` consistently hit `Timeout waiting for privilege escalation prompt` on this specific stack (Ubuntu 26.04, OpenSSH 10.2, tested across two ansible-core versions — 2.21.4 and 2.16.19). Ruled out: wrong password, `requiretty`, PAM/LDAP delays, SSH multiplexing, timeout length, and the `command` module specifically (`raw` failed identically). Since SSH key possession is already the sole real access control for `wolos`, NOPASSWD sudo doesn't meaningfully weaken security here. The password hash is kept in case this gets revisited.
- **OCI-specific assumption:** `hardening.yml` edits the main `/etc/ssh/sshd_config` directly rather than adding a drop-in under `sshd_config.d/`. This works because OCI's cloud-init drop-in only sets `PasswordAuthentication` (to the same value this playbook sets), and doesn't touch `AllowUsers` or `PermitRootLogin` at all. On a different cloud provider, a drop-in might silently override these settings — check `sshd -T` after running.
- **`AllowUsers wolos` alone would already block root and `ubuntu`** login; `PermitRootLogin no` is a deliberate second layer of defense.
- Every `sshd_config` change is validated with `sshd -t -f %s` before being written, and `ssh` is only restarted (via a handler) if a task actually changed something.

## Possible next steps

- Pin the `ansible.posix` collection version in `requirements.yml`
- Revisit password-based `become` if the underlying Ansible/OpenSSH/sudo interaction gets diagnosed further
- Use this alongside `oci-network-terraform` and a future CI step to fully automate provisioning + hardening