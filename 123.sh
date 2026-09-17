#!/bin/bash



ADS=(
  "cUfx:EU-FRANKFURT-1-AD-1"
  "cUfx:EU-FRANKFURT-1-AD-2"
  "cUfx:EU-FRANKFURT-1-AD-3"
)


# for i in "${reqvar[@]}"; do
#     if [[ -z "${!i}" ]]; then
#         err+=("błąd $i")
#     fi
# done


# if (( ${#err[@]} != 0 )); then
#     echo "tu są błędy ${err[*]}"
#     else
#         echo "brak błędów"
# fi


walidacja_zmiennych() {
  local reqvar=("TENANCY_ID" "DISCORD_WEBHOOK_URL" "SUBNET_ID" "IMAGE_ID")
  local err=()

  for i in "${reqvar[@]}"; do
    if [[ -z "${!i}" ]]; then
      err+=("błąd $i")
    fi
  done

  if (( ${#err[@]} == 0 )); then
    return 0
  else
    echo "${err[*]}"
    return 1
  fi
}


tworzenie_instancji() {
   local ad="$1"

   local cmd=(     oci compute instance launch                                       #tablica, nie sting z eval, bo się posypią znaki specjalne
        --availability-domain "$ad" 
        --compartment-id "$TENANCY_ID" 
        --shape "VM.Standard.A1.Flex" 
        --shape-config '{"ocpus": 2, "memory_in_gbs": 12}' 
        --image-id "$IMAGE_ID"
        --subnet-id "$SUBNET_ID" 
        --assign-public-ip true 
        --no-retry
        )

   local wynik

   wynik=$("${cmd[@]}" 2>&1)
   local status=$?                      #trzyma kod z ostaniej komendy
   
    if [[ $status -eq 0 ]]; then
      return 0
    else
        echo "$wynik"
        return $status
    fi

 }


discord() {
    local wiadomosc="$1"
    local payload
    payload=$(jq -n --arg tresc "$wiadomosc" '{content: $tresc}')

    curl -s --fail -X POST -H "Content-Type: application/json" -d "$payload" "$DISCORD_WEBHOOK_URL"
}


log() {                                                                     #bez logowania do pliku, docker będzie logował na dysk
    local wiadomosc="$1"
    local znacznik_czasu
    znacznik_czasu=$(date +"%d-%m-%Y %H.%M.%S" )

    echo "[$znacznik_czasu - $wiadomosc]" >&2
}

komunikat=$(walidacja_zmiennych)
if [[ $? -eq 0 ]]; then
  while true; do
    for AD in "${ADS[@]}"; do
      if wynik=$(tworzenie_instancji "$AD"); then
        discord "Sukces: utworzono instancję w strefie $AD" || log "Discord nie potwierdził wysyłki sukcesu"
        exit 0
      else
        log "$wynik"
        discord "$wynik" || log "Discord nie potwierdził wysyłki błędu"
      fi
    done
    sleep 10
  done
else
  log "$komunikat"
  discord "$komunikat" || log "Discord nie potwierdził wysyłki błędu walidacji"
  exit 1
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
