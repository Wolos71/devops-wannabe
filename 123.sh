#!/bin/bash

# ----- tymczasowe -----
set -a
source .env
set +a

# ----- tymczasowe -----


reqvar=("DISCORD_WEBHOOK_URL" "SUBNET_ID" "BOOT_VOLUME_ID" )
err=()         #tablica na błędy

pobierz_tenancy() {
    local zmienna=$(oci iam compartment list --query "data[0].\"compartment-id\"" --raw-output)
    echo "$zmienna"
}

TENANCY_ID=$(pobierz_tenancy)
echo "$TENANCY_ID"

for i in "${reqvar[@]}"; do
    if [[ -z "${!i}" ]]; then
        err+=("błąd $i")
    fi
done


if (( ${#err[@]} != 0 )); then
    echo "tu są błędy ${err[*]}"
    else
        echo "brak błędów"
fi

# tworzenie_instancji() {
#     local ad="$1"
#     echo "testy: oci compute instance launch \
#   --availability-domain "$ad" \
#   --compartment-id "$TENANCY_ID" \
#   --shape "VM.Standard.A1.Flex" \
#   --shape-config '{"ocpus": 2, "memory_in_gbs": 12}' \
#   --source-boot-volume-id "$BOOT_VOLUME_ID" \
#   --subnet-id "$SUBNET_ID" \
#   --assign-public-ip true 2>&1
# }




# walidacja
#   if
#     pętla while
#       pętla tworzenia po AD
#         if tworzenie instancji; then
#           discord sukces || błąd disord + log
#           exit
#         else
#         discrd ad blad + log
#         fi
#     wait 10s
#   else
#     błąd zmienych
#     echo błąd
#     log błąd
#     discord błąd              #pamiętaj obsługa błędów, pusty webhook
#     exit
#   fi
