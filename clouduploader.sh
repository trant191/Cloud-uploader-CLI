#!/bin/bash

#check the file path as an argument
if [ -z "$1" ]; then
    echo "Usage: Clouduploader /path/to/file"
    exit 1
fi

# Ask For Azure Account name and access key"
read -p "Enter your Azure Storage acount name: " AZURE_STORAGE_ACCOUNT
read -sp "Enter you Azure Storage access key: " AZURE_STORAGE_KEY
echo "..."
read -p "Enter your container name: " my_container 




# Azure storage detail
file_path="$1" #store file_path
blob_name=$(basename "$file_path") # extract file name from path

# Check if the required env var is set
if [ -z "$AZURE_STORAGE_ACCOUNT" ] || [ -z "$AZURE_STORAGE_KEY" ]; then
    echo "ERROR: Please set Azure_STORAGE_ACCOUNT and/or AZURE_STORAGE_KEY"
    exit 1
fi

# Upload file to azure Blob Storage
echo "Uploading $file_path to Azure Blob Storage...."

az storage blob upload \
    --account-name "$AZURE_STORAGE_ACCOUNT" \
    --account-key "$AZURE_STORAGE_KEY" \
    --container-name "$my_container" \
    --name "$blob_name" \
    --file "$file_path"

# Check file upload status
if [ $? -eq 0 ]; then
    echo "File uploaded successfully"
    echo "Generating sharable link..."

#set the expiration date for the SAS token
    expiry=$(date -u -d "1 day" '+%Y-%m-%dT%H:%MZ')

    sas_token=$(az storage blob generate-sas \
        --account-name "$AZURE_STORAGE_ACCOUNT" \
        --account-key "$AZURE_STORAGE_KEY" \
        --container-name "$my_container" \
        --name "$blob_name" \
        --expiry "$expiry"\
        --permission r\
        --output tsv)

    url="https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${my_container}/$blob_name?$sas_token"
    echo "Sharable URL Generated: $url"
else
    echo "File upload error"
    exit 1
fi


