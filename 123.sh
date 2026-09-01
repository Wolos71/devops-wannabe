#!/bin/bash

# ----- tymczasowe -----
set -a
source .env
set +a



# ----- tymczasowe -----


reqvar=("DISCORD_WEBHOOK_URL" "SUBNET_ID" "BOOT_VOLUME_ID" )
err=()         #tablica na błędy



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
