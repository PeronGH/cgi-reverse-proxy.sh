#!/bin/sh

target_url="${REQUEST_URI#$SCRIPT_NAME}"
target_url=$BASE_URL"${target_url#/}"

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

