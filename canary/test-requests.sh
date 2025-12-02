#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Defaults
DEFAULT_URL="http://localhost:8000"
DEFAULT_COUNT=100
DEFAULT_SLEEP=0.5

usage() {
    echo "Usage: $0 [URL] [COUNT] [SLEEP]"
    echo ""
    echo "Description:"
    echo "  Sends a series of HTTP GET requests to a specified URL and prints the content of the <h1> tag."
    echo ""
    echo "Arguments:"
    echo "  URL    Target URL (default: $DEFAULT_URL)"
    echo "  COUNT  Number of requests (default: $DEFAULT_COUNT). Use -1 for infinite loop."
    echo "  SLEEP  Seconds to wait between requests (default: $DEFAULT_SLEEP)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 http://192.168.64.2:30000"
    echo "  $0 http://localhost:8080 50 1"
    exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Trap Ctrl+C
trap "echo -e '\n${YELLOW}Stopped by user.${NC}'; exit 0" SIGINT

URL=${1:-$DEFAULT_URL}
COUNT=${2:-$DEFAULT_COUNT}
SLEEP=${3:-$DEFAULT_SLEEP}

if [ "$COUNT" -eq -1 ]; then
    COUNT_DISP="Infinite"
else
    COUNT_DISP="$COUNT"
fi

echo -e "🚀 Sending requests to ${YELLOW}$URL${NC} (Count: $COUNT_DISP, Sleep: ${SLEEP}s)"
echo "---------------------------------------------------"

i=1
while [[ "$COUNT" -eq -1 || $i -le "$COUNT" ]]; do
    # Capture output and exit code
    OUTPUT=$(curl -s --connect-timeout 2 "$URL")
    CURL_EXIT=$?

    if [ $CURL_EXIT -ne 0 ]; then
        echo -e "${RED}[$i] Connection failed (curl error $CURL_EXIT)${NC}"
    else
        # Try to extract H1
        H1=$(echo "$OUTPUT" | grep -o "<h1>.*</h1>" | sed 's/<h1>//;s/<\/h1>//')
        
        if [ -n "$H1" ]; then
            echo -e "${NC}[$i] Response: $H1${NC}"
        else
            echo -e "${YELLOW}[$i] Response received but no <h1> tag found${NC}"
        fi
    fi

    sleep "$SLEEP"
    ((i++))
done

echo "---------------------------------------------------"
echo "Done."
