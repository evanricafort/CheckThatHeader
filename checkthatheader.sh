#!/bin/bash
# Title: CheckThatHeader
# Description: A tool for checking low hanging fruit issues on headers using wget with a twist of nmap.
# Author: Evan Ricafort - https://evanricafort.com | X: @evanricafort

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Create results directory
RESULTS_DIR="Result"
mkdir -p "$RESULTS_DIR"

# Output files
OUTPUT_FILE="$RESULTS_DIR/scan_result.txt"
WGET_LOG_FILE="$RESULTS_DIR/wget-logs"

# Function to check headers
check_headers() {
    local url=$1

    # Fetch headers using wget with verbose output and log to file
    headers=$(wget -d --verbose --spider --server-response --timeout=10 --tries=1 "$url" 2>&1 | tee -a "$WGET_LOG_FILE" | grep -i -e "Content-Security-Policy" -e "Permissions-Policy" -e "Referrer-Policy" -e "X-Content-Type-Options" -e "Strict-Transport-Security" -e "X-Frame-Options")

    # Check for each header
    check_header "Content-Security-Policy" "$headers" "$url"
    check_header "Permissions-Policy" "$headers" "$url"
    check_header "Referrer-Policy" "$headers" "$url"
    check_header "X-Content-Type-Options" "$headers" "$url"
    check_header "Strict-Transport-Security" "$headers" "$url"
    check_header "X-Frame-Options" "$headers" "$url"
}

# Function to check a single header
check_header() {
    local header=$1
    local headers=$2
    local url=$3

    if echo "$headers" | grep -i "$header:" > /dev/null; then
        echo -e "${GREEN}${header} header found${NC}"
        echo "$url: ${header} header found" >> "$OUTPUT_FILE"
    else
        echo -e "${RED}${header} header missing${NC}"
        echo "$url: ${header} header missing" >> "$OUTPUT_FILE"
    fi
}

# Function to process a single URL
process_url() {
    local url=$1
    echo "Processing $url"

    # Fetch headers using wget with verbose output and log to file
    wget_output=$(wget -d --verbose --spider --server-response --timeout=10 --tries=1 "$url" 2>&1 | tee -a "$WGET_LOG_FILE")

    # Check for connection errors
    if echo "$wget_output" | grep -q -e "Connection timed out" -e "Giving up"; then
        echo -e "${RED}Target is Unreachable${NC}"
        echo "$url: Target is Unreachable" >> "$OUTPUT_FILE"
    else
        check_headers "$url"
    fi
}

# Function to process a list of URLs or a subnet
process_targets() {
    local target=$1
    if [[ "$target" == *"/"* ]]; then
        # Assume it's a subnet
        # This is a simple example, modify as needed to handle subnets
        for ip in $(nmap -n -sP "$target" | grep 'Nmap scan report for' | awk '{print $5}'); do
            process_url "$ip"
        done
    else
        # Assume it's a list of URLs
        while IFS= read -r line; do
            process_url "$line"
        done < "$target"
    fi
}

# Function to display usage information
usage() {
    echo "Usage: $0 -u <SINGLE_TARGET> | -t <MULTIPLE_TARGET/SUBNET>"
    exit 1
}

# Main script
if [[ $# -lt 2 ]]; then
    usage
fi

while getopts "u:t:h" opt; do
    case ${opt} in
        u)
            url=${OPTARG}
            process_url "$url"
            ;;
        t)
            target=${OPTARG}
            process_targets "$target"
            ;;
        h)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done

echo "Results saved to $OUTPUT_FILE"
echo "Wget logs saved to $WGET_LOG_FILE"
