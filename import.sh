#!/usr/bin/bash

# Load environment variables from SECRET_MOUNT_ folders
for secret_env_var in $(env | grep '^SECRET_MOUNT_' | awk -F= '{print $1}'); do
  folder_path="${!secret_env_var}"

  if [ -d "$folder_path" ]; then
    echo "Processing folder: $folder_path"

    while IFS= read -r env_file; do
      env_var_name=$(basename "$env_file" .env)

      if [ -r "$env_file" ]; then
        env_value=$(<"$env_file")
        export "$env_var_name=$env_value"
        echo "Exported $env_var_name from $env_file"
      else
        echo "Cannot read $env_file"
      fi
    done < <(find "$folder_path" -type f -name "*.env")
  else
    echo "Folder $folder_path does not exist"
  fi
done