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

# Get all processes adn services between them
declare -A services
service_name=""
while read -r line; do
    if [[ "$line" =~ ^[[:alpha:]]+$ ]]; then
        services["$line"]="Active"
        service_name="$line"
    else
        if [[ "$line" == *"remove"* ]]; then
            services["$service_name"]="Stopped"
        fi
    fi
done < <(grep -oP "'name'\s*=>\s'\K[^']+|\[pid\s*[0-9]*\]\s*\[[^\]]*\]" "$logfile" | uniq)

cat <<EOF > service_script_output.txt
List services and their status: 
$(for key in "${!services[@]}"; do
    echo "$key: ${services[$key]}"
done)
EOF

echo "List services and their status:"
for key in "${!services[@]}"; do
    echo "$key: ${services[$key]}"
done

