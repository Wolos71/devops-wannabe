#!/bin/bash

# --- KONFIGURACJA ZMIENNYCH ---
BOOT_VOLUME_ID="ocid1.bootvolume.oc1.eu-frankfurt-1.abtheljto53ldkawcqrlx3ij7bhv65z53n6fm4d4v466ger3dmjurvx2t7ea"
SUBNET_ID="ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaakt6gx3qav4irvdfjxsy4wjky3xbkgbfw5lcm2eqrlbvtdnoma65q"

# Lista wszystkich stref dostępności w Twoim regionie
ADS=(
  "cUfx:EU-FRANKFURT-1-AD-1"
  "cUfx:EU-FRANKFURT-1-AD-2"
  "cUfx:EU-FRANKFURT-1-AD-3"
)



while true; do
  # Pobieramy ID przedziału automatycznie
  TENANCY_ID=$(oci iam compartment list --query "data[0].\"compartment-id\"" --raw-output 2>/dev/null)

  # Sprawdzamy po kolei każdą strefę z listy
  for AD in "${ADS[@]}"; do
    echo "🔍 Próba utworzenia w strefie: $AD ..."
    
    OUTPUT=$(oci compute instance launch \
      --availability-domain "$AD" \
      --compartment-id "$TENANCY_ID" \
      --shape "VM.Standard.A1.Flex" \
      --shape-config '{"ocpus": 2, "memory_in_gbs": 12}' \
      --source-boot-volume-id "$BOOT_VOLUME_ID" \
      --subnet-id "$SUBNET_ID" \
      --assign-public-ip true 2>&1)

    # Sprawdzenie, czy się udało
    if [[ $? -eq 0 ]]; then
      echo "🎉 Sukces! Maszyna została utworzona w strefie $AD!"
      curl -H "Content-Type: application/json" \
           -X POST \
           -d '{"content": "done, masz vpsa"}' \
           "$DISCORD_WEBHOOK_URL"
      exit 0
    fi
  done

  echo "⏳ [$(date +'%H:%M:%S')] Brak miejsca we wszystkich strefach. Czekam 60 sekund..."
  sleep 2
done
