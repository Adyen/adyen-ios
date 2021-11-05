#!/bin/sh

IS_THERE_OUTPUT=false
function check() {
  touch temp_output
  mint run ezura/spell-checker-for-swift@5.3.0 "$1" > temp_output
  cat temp_output
  OUTPUT=$(grep 'warning' temp_output)
  if [[ ! -z "$OUTPUT" ]]; then
    IS_THERE_OUTPUT=true
  fi
}
check "Adyen"
check "AdyenActions"
check "AdyenCard"
check "AdyenComponents"
check "AdyenDropIn"
check "AdyenEncryption"
check "AdyenSwiftUI"
check "AdyenWeChatPay"
check "Demo"

if [[ "$IS_THERE_OUTPUT" = true ]]; then
  exit 1
fi
