#!/bin/sh

internal_error() {
  echo 'Status: 500 Internal Server Error'
  echo
  for msg in "$@"; do
    echo "$msg"
  done
  exit 1
}

base_url=$1

if [ -z $base_url ]; then
  internal_error 'base_url not set.'
fi

target_url="${REQUEST_URI#$SCRIPT_NAME}"
target_url=$base_url"${target_url#/}"

headers=`mktemp`
printenv | awk -F'=' '/^HTTP_/ {
    key = substr($1, 6);
    if (key == "HOST") next;
    gsub("_", "-", key);
    value = substr($0, length($1) + 2);
    printf "%s: %s\n", key, value
}' > $headers

curl -si -X $REQUEST_METHOD -d @- $target_url -H @$headers | {
  if { [ -n "$https_proxy" ] || [ -n "$HTTPS_PROXY" ]; } && [[ "$target_url" == https://* ]]; then
    read > /dev/null
    read > /dev/null
  fi
  read -r status_line
  echo $status_line | awk '{$1="Status:"; print}'
  cat
}

rm $headers

