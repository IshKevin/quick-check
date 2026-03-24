#!/bin/bash
# A simple monitor script

echo "Checking system..."
df -h | grep '^/dev/' # disk usage
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
uptime | awk '{print "CPU Load:", $10}'
echo "Done!"