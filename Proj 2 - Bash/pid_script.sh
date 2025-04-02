#!/bin/bash

# Check if a file was provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

# Store the filename from the first argument
logfile="$1"

# Check if the file exists
if [ ! -f "$logfile" ]; then
    echo "Error: File '$logfile' not found."
    exit 1
fi

# Extract all PIDs
pid_all=`grep -o '\[pid [0-9]*\]' "$logfile"`

# Extract only numbers
pid_numbers=`grep -o '\[pid [0-9]*\]' "$logfile" | grep -o '[0-9]*'`

# Sort numbers and get rid of all the non-unique ones
pid_unique=`grep -o '\[pid [0-9]*\]' "$logfile" | grep -o '[0-9]*' | sort -u`

# Count the number of new lines
pid_quantity=`grep -o '\[pid [0-9]*\]' "$logfile" | grep -o '[0-9]*' | sort -u | wc -l`

# Writing all outputs to the pid_script_output.txt file
cat <<EOF > pid_script_output.txt
Extract all PIDs from logfile: 
$pid_all
Extract only numbers:
$pid_numbers
Sort numbers and get rid of all the non-unique ones:
$pid_unique
Count the number of new lines: 
$pid_quantity
EOF
