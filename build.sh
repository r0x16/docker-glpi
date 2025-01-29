#!/bin/bash

VERSION="10.0.17"

# Name of the downloaded file
FILENAME="glpi-$VERSION.tgz"

# URL of GLPI compressed file
URL="https://github.com/glpi-project/glpi/releases/download/$VERSION/$FILENAME"

# Download the file
if command -v curl &> /dev/null; then
    echo "Downloading with curl..."
    curl -L -o "$FILENAME" "$URL"
elif command -v wget &> /dev/null; then
    echo "Downloading with wget..."
    wget -O "$FILENAME" "$URL"
else
    echo "Error: Neither curl nor wget found for downloading the file."
    exit 1
fi

# Verify if the download was successful
if [ ! -f "$FILENAME" ]; then
    echo "Error: Download failed."
    exit 1
fi

echo "Extracting $FILENAME..."
# Extract the file in the current directory
tar -xvzf "$FILENAME"

# Verify if the extraction was successful
if [ $? -eq 0 ]; then
    echo "Extraction completed successfully."
else
    echo "Error: Extraction failed."
    exit 1
fi

# Build docker image
docker build -t glpi:$VERSION .