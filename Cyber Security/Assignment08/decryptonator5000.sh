#!/bin/bash
set -euo pipefail

TARGET_DIR="../target"
DATA_DIR="$HOME/data"
PRIV_KEY="$DATA_DIR/priv.key"
RSA_EXEC="./rsa"


if [[ ! -f "$PRIV_KEY" ]]; then
  echo "Error: Private key not found at $PRIV_KEY"
  exit 1
fi

echo "Searching directory: $TARGET_DIR"
echo "Using private key: $PRIV_KEY"
echo

find "$TARGET_DIR" -type f -name "*.enc" -print0 | while IFS= read -r -d '' enc_file; do
  orig_file="${enc_file%.enc}"

  echo "Decrypting: $enc_file -> $orig_file"

  "$RSA_EXEC" -i "$enc_file" -o "$orig_file" -k "$PRIV_KEY" -d

  if [[ -f "$orig_file" ]]; then
    rm "$enc_file"
    echo "Deleted encrypted file: $enc_file"
  else
    echo "Decryption failed for $enc_file (keeping encrypted file)"
  fi
done

echo
echo "Decryption complete."
