#!/usr/bin/env bash
set -euo pipefail

RSA_EXEC="./rsa"

usage() {
  echo "Usage:"
  echo "  $0 -g N <target_dir>    # Generate N files in <target_dir> and encrypt them"
  echo "  $0 -s <target_dir>      # Select existing files from <target_dir> to encrypt"
  exit 1
}

generate_files() {
  local N="$1"
  local TARGET_DIR="$2"

  if ! [[ "$N" =~ ^[0-9]+$ ]] || [[ "$N" -le 0 ]]; then
    echo "Error: N must be a positive integer"
    exit 1
  fi

  selected_files=()

  echo "Generating $N file(s) in $TARGET_DIR..."
  for ((i=1; i<=N; i++)); do
    file="$TARGET_DIR/file_$i.txt"
    echo "A totally normal and safe unencrypted file number: $i" > "$file"
    echo "Created $file"
    selected_files+=("$file")
  done
  echo "Done."

  encrypt_files
}

select_files() {
  local TARGET_DIR="$1"

  files=("$TARGET_DIR"/*)
  if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in $TARGET_DIR."
    exit 0
  fi

  echo "Existing files in $TARGET_DIR:"
  for i in "${!files[@]}"; do
    printf "%3d) %s\n" $((i+1)) "$(basename "${files[$i]}")"
  done

  read -rp "Select files by numbers (space-separated, or Enter to exit): " -a selections

  if [ ${#selections[@]} -eq 0 ]; then
    echo "No selection made. Exiting."
    exit 0
  fi

  selected_files=()
  for idx in "${selections[@]}"; do
    if ! [[ "$idx" =~ ^[0-9]+$ ]] || (( idx < 1 || idx > ${#files[@]} )); then
      echo "Invalid selection: $idx"
      continue
    fi
    selected_files+=("${files[$((idx-1))]}")
  done
}

# ------------------------
# Encryption
# ------------------------
encrypt_files() {
  DATA_DIR="$HOME/data"

  if [[ ! -f "$DATA_DIR/pub.key" || ! -f "$DATA_DIR/priv.key" ]]; then
    "$RSA_EXEC" -g 4098
    mv pub.key "$DATA_DIR/pub.key"
    mv priv.key "$DATA_DIR/priv.key"
  fi

  PUB_KEY="$DATA_DIR/pub.key"

  # Encrypt selected files
  for file in "${selected_files[@]}"; do
    enc_file="${file}.enc"
    echo "Encrypting $file -> $enc_file"

    "$RSA_EXEC" -i "$file" -o "$enc_file" -k "$PUB_KEY" -e

    if [ -f "$enc_file" ]; then
      rm "$file"
      echo "Deleted original: $file"
    else
      echo "Encryption failed for $file, original kept."
    fi
  done
}



if [[ "$#" -eq 3 && "$1" == "-g" ]]; then
  N="$2"
  TARGET_DIR="$3"
  generate_files "$N" "$TARGET_DIR"

elif [[ "$#" -eq 2 && "$1" == "-s" ]]; then
  TARGET_DIR="$2"
  select_files "$TARGET_DIR"
  encrypt_files

else
  usage
fi

echo "All done."
