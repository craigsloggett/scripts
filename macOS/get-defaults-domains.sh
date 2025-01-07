#!/bin/sh

output_filename="defaults-by-domain.txt"
domains="$(defaults domains | tr ',' '\n' | tr -d ' ' | sort -u)"

: >"${output_filename}"

defaults domains | tr ',' '\n' | tr -d ' ' | sort -u |
  while read -r domain; do
    printf '\n%s\n' "Attempting to read the domain it using the defaults command..."
    printf '%s\n' "defaults read ${domain}"
    if ! defaults read "${domain}" >/dev/null 2>&1; then
      printf '%s\n' "The defaults command failed to read the domain."
    else
      printf '%s\n' "Success! Adding the domain to a list for future use."
      printf '%s\n' "${domain}" >>"${output_filename}"
    fi
  done

find ~/Library/Preferences -type f -name "*.plist" |
  while read -r plist; do
    printf '\n%s\n' "Searching for ${plist} in default domains..."
    domain="$(basename "${plist}" '.plist')"
    if printf '%s\n' "${domains}" | grep -qx "${domain}"; then
      printf '%s\n' "The plist was found in the default domains list, attempting to read it using the defaults command..."
      printf '%s\n' "defaults read ${domain}"
      if ! defaults read "${domain}" >/dev/null 2>&1; then
        printf '%s\n' "The defaults command failed to read the domain."
      else
        printf '%s\n' "Success! Adding the domain to a list for future use."
        printf '%s\n' "${domain}" >>"${output_filename}"
      fi
    else
      printf '%s\n' "N"
    fi
  done

sort -u "${output_filename}" -o "${output_filename}"
