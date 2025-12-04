#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
DEFAULT_URL="http://localhost"
DEFAULT_COUNT=100
DEFAULT_SLEEP=0.5
MODE="public"

usage() {
    echo "Usage: $0 [options] [URL] [COUNT] [SLEEP]"
    echo ""
    echo "Description:"
    echo "  Sends HTTP GET requests to a URL to verify header-based routing."
    echo ""
    echo "Options:"
    echo "  --public   Simulate a public user (no headers). Default."
    echo "  --tester   Simulate an internal tester (sends 'x-canary: true')."
    echo "  -h, --help Show this help message."
    echo ""
    echo "Arguments:"
    echo "  URL        Target URL (default: $DEFAULT_URL)"
    echo "  COUNT      Number of requests (default: $DEFAULT_COUNT). Use -1 for infinite."
    echo "  SLEEP      Seconds to wait between requests (default: $DEFAULT_SLEEP)"
    echo ""
    echo "Examples:"
    echo "  $0 --public"
    echo "  $0 --tester"
    echo "  $0 --tester http://localhost:8080"
    exit 0
}

# Parse arguments
ARG_URL=""
ARG_COUNT=""
ARG_SLEEP=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --tester)
            MODE="tester"
            shift
            ;;
        --public)
            MODE="public"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [ -z "$ARG_URL" ]; then
                ARG_URL="$1"
            elif [ -z "$ARG_COUNT" ]; then
                ARG_COUNT="$1"
            elif [ -z "$ARG_SLEEP" ]; then
                ARG_SLEEP="$1"
            fi
            shift
            ;;
    esac
done

URL=${ARG_URL:-$DEFAULT_URL}
COUNT=${ARG_COUNT:-$DEFAULT_COUNT}
SLEEP=${ARG_SLEEP:-$DEFAULT_SLEEP}

if [ "$COUNT" -eq -1 ]; then
    COUNT_DISP="Infinite"
else
    COUNT_DISP="$COUNT"
fi

# Configure Header
if [ "$MODE" == "tester" ]; then
    USER_TYPE="${GREEN}TESTER (x-canary: true)${NC}"
else
    USER_TYPE="${BLUE}PUBLIC (No Headers)${NC}"
fi

echo -e "🚀 Sending requests to ${YELLOW}$URL${NC}"
echo -e "👤 User Mode: $USER_TYPE"
echo -e "🔢 Count: $COUNT_DISP, Sleep: ${SLEEP}s"
echo "---------------------------------------------------"

# Trap Ctrl+C
trap "echo -e '\n${YELLOW}Stopped by user.${NC}'; exit 0" SIGINT

i=1
while [[ "$COUNT" -eq -1 || $i -le "$COUNT" ]]; do
    # Construct curl command
    if [ "$MODE" == "tester" ]; then
        RESPONSE=$(curl -s -w "\n%{http_code}" --connect-timeout 2 -H "x-canary: true" "$URL")
    else
        RESPONSE=$(curl -s -w "\n%{http_code}" --connect-timeout 2 "$URL")
    fi
    CURL_EXIT=$?

    if [ $CURL_EXIT -ne 0 ]; then
        echo -e "${RED}[$i] Connection failed (curl error $CURL_EXIT)${NC}"
    else
        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        OUTPUT=$(echo "$RESPONSE" | sed '$d')

        if [[ "$HTTP_CODE" =~ ^[23] ]]; then
            # Try to extract H1
            H1=$(echo "$OUTPUT" | grep -o "<h1>.*</h1>" | sed 's/<h1>//;s/<\/h1>//')
            
            if [ -n "$H1" ]; then
                echo -e "[$i] Response: ${NC}$H1${NC}"
            else
                echo -e "${YELLOW}[$i] Response received ($HTTP_CODE) but no <h1> tag found${NC}"
            fi
        else
            echo -e "${RED}[$i] Request failed with status $HTTP_CODE${NC}"
        fi
    fi

    sleep "$SLEEP"
    ((i++))
done

echo "---------------------------------------------------"
echo "Done."
