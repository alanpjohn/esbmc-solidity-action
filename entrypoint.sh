#!/bin/bash

# Check if es.yml is present

CONFIG_FILE=es.yml
BUGS_FOUND=false

if [ -f "$CONFIG_FILE" ]; then
    echo "$CONFIG_FILE exists."
else
    echo "Error: $CONFIG_FILE file not found"
    exit 2
fi

echo ""
echo "SOFTWARE VERSIONS"
echo ""

echo "      "$(esbmc --version)
echo "      "$(solc --version)
echo "      "$(yq -V)

echo ""
echo "RUNNING ESBMC-SOLIDITY"
echo ""

# Parse es.yml file

readarray fileMappings < <(yq e -I=0 -j '.files[]' es.yml )

for fileMapping in "${fileMappings[@]}"; do
    # identity mapping is a yaml snippet representing a single entry
    # echo $fileMapping
    filepath=$(echo "$fileMapping" | yq e '.filepath' -)
    astfile=${filepath}ast

    readarray funcs < <(echo "$fileMapping" | yq e -I=0 -j '.functions[]' -)
    for funcMapping in "${funcs[@]}"; do
    
        func=$(echo "$funcMapping" | yq e '' - | tr -d '"')

        echo ""
        echo "Verifying function: $func in $filepath"
        echo ""
        
        (solc --ast-compact-json $filepath > $astfile) > /dev/null
        if esbmc $astfile --function $func --contract $filepath --z3 --compact-trace --incremental-bmc > output.log; then 
            echo "Verification Successful"
        else
            cat output.log | sed 's/^/     /'
            BUGS_FOUND=true
        fi
    done
done

if $BUGS_FOUND; then
    # cat output.log | sed 's/^/     /' 
    exit 255
else
    exit 0
fi