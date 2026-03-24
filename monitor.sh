#!/bin/bash

# Configuration & Constants
DISK_THRESHOLD=80
MEM_THRESHOLD=90
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function: Display usage and exit
usage() {
    echo "Usage: $0 [-d] [-m] [-h]"
    echo "  -d    Check Disk Usage"
    echo "  -m    Check Memory Usage"
    echo "  -h    Display Help"
    exit 1
}

check_disk() {
    echo -e "${GREEN}--- Disk Usage ---${NC}"
    # Filter for physical disks and check percentage
    df -h | grep '^/dev/' | while read -r line; do
        usage_pct=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        if [ "$usage_pct" -gt "$DISK_THRESHOLD" ]; then
            echo -e "${RED}ALERT: $line${NC}"
        else
            echo "$line"
        fi
    done
}

check_mem() {
    echo -e "${GREEN}--- Memory Usage ---${NC}"
    if ! command -v free &> /dev/null; then
        echo "Error: 'free' command not found."
        return 1
    fi
    free -m | awk -v thresh="$MEM_THRESHOLD" 'NR==2{
        pct=$3*100/$2; 
        if(pct > thresh) { print "\033[0;31mCRITICAL: " pct "% used\033[0m" }
        else { print "Usage: " $3 "MB / " $2 "MB (" pct "%)" }
    }'
}

# Parse flags
if [ $# -eq 0 ]; then
    check_disk
    check_mem
else
    while getopts "dmh" opt; do
        case $opt in
            d) check_disk ;;
            m) check_mem ;;
            h|*) usage ;;
        esac
    done
fi