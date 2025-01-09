#!/bin/sh

output_filename="defaults-by-domain.txt"

# Clear the list of defaults available.
: >"${output_filename}"

# Get a list of domains available by default to the `defaults` command.
domains="$(defaults domains | tr ',' '\n' | tr -d ' ' | sort -u)"

printf '%s\n' "${domains}" |
  while read -r domain; do
    # Even though this domain appears in `defaults domains`, it may be
    # restricted, ephemeral, or otherwise unreadable. We run `defaults read`
    # to confirm it actually contains readable preferences. If this fails,
    # we skip it.
    if defaults read "${domain}" >/dev/null 2>&1; then
      printf '%s\n' "${domain}" >>"${output_filename}"
    fi
  done

# There are domains available to a regular user that can be specified by domain
# (not the full path) that are not listed using the `defaults domains` command.
find ~/Library/Preferences -type f -name "*.plist" |
  while read -r plist; do
    # Get the domain from the full path in the same format as those available
    # by the `defaults` command.
    domain="$(basename "${plist}" '.plist')"

    # We have already gone over the domains listed by the `defaults domains`
    # command so we take only domains that are not listed.
    if ! printf '%s\n' "${domains}" | grep -qx "${domain}"; then
      # Even though this domain has an associated plist file, it may be
      # restricted, ephemeral, or otherwise unreadable. We run `defaults read`
      # to confirm it actually contains readable preferences. If this fails,
      # we skip it.
      if defaults read "${domain}" >/dev/null 2>&1; then
        printf '%s\n' "${domain}" >>"${output_filename}"
      fi
    fi
  done

sort -u "${output_filename}" -o "${output_filename}"
