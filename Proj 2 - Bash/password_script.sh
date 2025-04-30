#!/bin/bash

# Check if a file was provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

# Store the file path
LOG_FILE=$1

# Check if the file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File '$LOG_FILE' not found."
    exit 1
fi

# Use grep to extract passwords from the file and process each one
grep -oP "pass'\s*=>\s*'\K[^']+" "$LOG_FILE" | while read -r password; do
    # Initialize flags for each requirement
    length_ok=0
    has_uppercase=0
    has_lowercase=0
    has_number=0
    has_special=0
    
    # Check password length (at least 10 characters)
    if [ ${#password} -ge 10 ]; then
        length_ok=1
    fi
    
    # Check for uppercase letter
    if [[ "$password" =~ [A-Z] ]]; then
        has_uppercase=1
    fi
    
    # Check for lowercase letter
    if [[ "$password" =~ [a-z] ]]; then
        has_lowercase=1
    fi
    
    # Check for number
    if [[ "$password" =~ [0-9] ]]; then
        has_number=1
    fi
    
    # Check for at least 2 special characters
    if [[ $(tr -d '[:alnum:][:space:]' <<< "$password" | wc -c) -ge 2 ]]; then
	has_special=1
    fi

    # Determine if the password is strong or weak
    if [ $length_ok -eq 1 ] && [ $has_uppercase -eq 1 ] && [ $has_lowercase -eq 1 ] && [ $has_number -eq 1 ] && [ $has_special -eq 1 ]; then
        strength="STRONG"
    else
        strength="WEAK"
        
        # Create a list of missing requirements
        missing=""
        [ $length_ok -eq 0 ] && missing+="Length (< 10 chars) "
        [ $has_uppercase -eq 0 ] && missing+="Uppercase "
        [ $has_lowercase -eq 0 ] && missing+="Lowercase "
        [ $has_number -eq 0 ] && missing+="Number "
        [ $has_special -eq 0 ] && missing+="Special chars less than 2 "
        
        strength+=" (Missing: $missing)"
    fi
    
    # Output the password and its strength to password_script_output.txt
    echo "Password: '$password' - $strength" >> password_script_output.txt
    echo "Password: '$password' - $strength"
done
