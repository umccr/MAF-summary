#!/bin/bash

# Specify the directory to list
directory="/Users/kanwals/UMCCR/git/apgi_metadata/ICAV1/WGS/03-umccrise/launch-templates"

# Specify the output file
output_file="output.csv"

# List the contents of the directory and format the output
for entry in "$directory"/*; do
    # Extract the filename without the path
    filename=$(basename "$entry")
    
    # Remove any leading/trailing whitespace or quotes
    filename=$(echo "$filename" | sed -e 's/^ *//' -e 's/ *$//' -e 's/"//g')
    
    # Write the formatted filename to the output file with a comma
    echo "'$filename'," >> "$output_file"
done
