#!/bin/sh

# Available configuration that can be set using the `defaults` command:

# User preferences:
#
# defaults read -g # (this is equal to `defaults read .GlobalPreferences`)
# defaults read <domain>
# defaults read <path_to_plist_file>
#
# System preferences:
#
# sudo defaults read -g # (this is equivalent to `sudo defaults read .GlobalPreferences`)
# sudo defaults read <domain>
# sudo defaults read <path_to_plist_file>

# Currently known locations of plist files:
#
# ~/Library/Preferences/
# ~/Library/Containers/
# /Library/Preferences/
# /Library/Managed Preferences/

defaults_by_domain_filename="defaults-by-domain.txt"
defaults_by_path_filename="defaults-by-path.txt"

# Clear the list of available defaults.
: >"${defaults_by_domain_filename}"
: >"${defaults_by_path_filename}"

# Get a list of domains available by default to the `defaults` command.
domains="$(defaults domains | tr ',' '\n' | sed 's/^ *//' | sort -u)"

printf '%s\n' "${domains}" |
  while read -r domain; do

    # Even though this domain appears in `defaults domains`, it may be
    # restricted, ephemeral, or otherwise unreadable. We run `defaults read`
    # to confirm it actually contains readable preferences. If this fails,
    # we skip it.
    if defaults read "${domain}" >/dev/null 2>&1; then
      printf '%s\n' "${domain}" >>"${defaults_by_domain_filename}"

      # TODO: Begin implementing key iteration.
      keys="$(defaults read "${domain}" | awk -F= '/=/ {print $1}' | tr -d '"' | sed 's/^ *//')"
      printf '%s\n' "${keys}" |
        while read -r key; do
          printf '%s\n' "defaults write ${domain} ${key} -bool true # TODO: Update type flag and value with defaults." >>defaults.txt
        done
    fi
  done

# There are domains available to a regular user that can be specified by domain
# (not the full path) that are not listed using the `defaults domains` command.
for directory in "${HOME}/Library/Preferences" "${HOME}/Library/Containers"; do

  # Some directories might not exist on a clean install.
  if [ -d "${directory}" ]; then
    # Some of the directories have restricted access so we run `find` against the
    # directory and if it fails, we skip it.
    if find "${directory}" >/dev/null 2>&1; then

      find "${directory}" -type f -name "*.plist" |
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
              printf '%s\n' "${domain}" >>"${defaults_by_domain_filename}"
            else

              # And the same but for the domains that must be specified using the
              # full path to the plist file.
              if defaults read "${plist}" >/dev/null 2>&1; then
                printf '%s\n' "${plist}" >>"${defaults_by_path_filename}"
              fi
            fi
          else

            # Capture the domains that are in the `defaults domains` list but
            # fail to be read by the `defaults read` command using the domain.
            if ! defaults read "${domain}" >/dev/null 2>&1; then

              # Attempt to read the domain using the full path to the plist file.
              if defaults read "${plist}" >/dev/null 2>&1; then
                printf '%s\n' "${plist}" >>"${defaults_by_path_filename}"
              fi
            fi
          fi
        done
    fi
  fi
done

sort -u "${defaults_by_domain_filename}" -o "${defaults_by_domain_filename}"
sort -u "${defaults_by_path_filename}" -o "${defaults_by_path_filename}"
