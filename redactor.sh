#!/bin/bash

# Check if a directory path was provided as an argument
if [ -z "$1" ]; then
    echo "Please provide a directory path as an argument."
    exit 1
fi

# Define the words to redact:
redact_words=("Cat" "Dog" "Horse")

# WHat you want to replace those words with:
replacement=("REDACTED")

# Function to recursively process files in a directory
process_directory() {
    local dir="$1"
    local changed_files=()

    # Iterate through all files and directories in the current directory
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            # Recursively process subdirectories
            process_directory "$item"
        elif [ -f "$item" ]; then
            # Process regular files
            for word in "${redact_words[@]}"; do
                if grep -q "$word" "$item"; then
                    # Redact the word and save the file path
                    sed -i "s/$word/$replacement/g" "$item"
                    changed_files+=("$item")
                fi
            done
        fi
    done

    # Return the list of changed files
    echo "${changed_files[@]}"
}

# Call the function with the provided directory path
changed_files=($(process_directory "$1"))

# Display the list of changed files
if [ ${#changed_files[@]} -eq 0 ]; then
    echo "No files were changed."
else
    echo "The following files were changed:"
    for file in "${changed_files[@]}"; do
        echo "- $file"
    done
fi
