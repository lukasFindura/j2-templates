#!/usr/bin/env bash -o pipefail

if [[ "$1" == "debug" ]]; then
    set -x
fi

DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

source $DIR/.variables.env

GREEN="\033[1;92m"
RED="\033[1;91m"
RESET="\033[0m"

echo >&2

FILE=$(pypick-file $DIR) || exit 
# grep extracts "{{...}}", sed extracts content
J2_VARS=$(cat $FILE | grep -o '{{[^}]*}}' | sed 's/{{//;s/}}//' | sort | uniq)

echo -e "\nChecking Jinja values...\n" >&2

for var in $J2_VARS; do
  val=$(envsubst <<< "\$$var")
  if [[ -n "$val" ]]; then
    output+="$GREEN$var\t$val$RESET\n"
  else
    output+="$RED$var\t\"\"$RESET\n"
    missing+="$var "
  fi
done

echo -e "$output" | sort -k2 -r | column -t -s $'\t' >&2

echo >&2

while :;
do
  choice=$(echo -e "1.\tcontinue\n2.\tedit all\n3.\tedit missing\n4.\tshow raw\n5.\tshow render" | column -t -s $'\t' | pypick -c) || exit 1
  choice=$(awk '{print $1}' <<< "$choice")
  if [[ "$choice" == "4." ]]; then
    cat $FILE >&2; echo >&2
  elif [[ "$choice" == "5." ]]; then
    j2 --undefined $FILE | jq >&2
  else
    break
  fi
done

echo >&2

if [[ "$choice" == "3." ]]; then
    for var in $missing; do
        read -e -p "$var: " -i "" val
        export "$var=$val"
    done
elif [[ "$choice" == "2." ]]; then
    for var in $J2_VARS; do
        read -e -p "$var: " -i "${!var}" val
        export "$var=$val"
    done
else
    :
fi

j2 --undefined $FILE | jq