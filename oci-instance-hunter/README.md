# OCI Instance Hunter

Oracle Cloud's free tier (ARM Ampere A1.Flex) is frequently out of capacity in popular regions. This tool retries instance creation across all availability domains in a region until one succeeds, running as a containerized bash script with Discord notifications.

## What it does

- Validates required configuration on startup (fail-fast, reports all missing variables at once)
- Attempts to launch a compute instance in each availability domain in turn
- On failure: logs the error and notifies Discord, then moves to the next zone
- On success: notifies Discord and exits
- Waits between retry rounds if all zones are unavailable in that pass

## Stack

- Bash (functions, arrays, `local` scoping, separated output/exit-code handling)
- OCI CLI
- Docker (credentials mounted as a volume, not baked into the image)
- Discord webhooks (`curl` + `jq` for safe JSON construction)

## Setup

1. Copy `.env.example` to `.env` and fill in your values (see table below)
2. Configure the OCI CLI on the host (`oci setup config`) so `~/.oci` exists there
3. Build: `docker build -t oci-instance-hunter .`
4. Run: `docker run -d --env-file .env -v ~/.oci:/root/.oci --name oci-instance-hunter oci-instance-hunter`
5. Follow logs: `docker logs -f oci-instance-hunter`

## Required environment variables

| Variable | Description |
|---|---|
| `TENANCY_ID` | OCI tenancy OCID (used as compartment ID) |
| `SUBNET_ID` | Subnet OCID to attach the instance to |
| `IMAGE_ID` | OS image OCID to boot the instance from |
| `DISCORD_WEBHOOK_URL` | Discord webhook URL for notifications |

## Design notes

- Credentials (`~/.oci`) are mounted as a Docker volume rather than copied into the image, to avoid baking secrets into image layers
- The OCI CLI's built-in retry/backoff is disabled (`--no-retry`) so all retry logic lives in one place — the script's own loop
- Known next step: classify errors as fatal vs. retryable (currently every failure is treated as retryable)