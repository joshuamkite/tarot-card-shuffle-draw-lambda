#!/bin/bash
# Comprehensive API Gateway connection test
# Tests CORS preflight, POST requests, and provides debugging guidance
#
# Update API_URL and ORIGIN variables below to match your deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration - UPDATE THESE VALUES FOR YOUR DEPLOYMENT
API_URL="${API_URL:-https://your-backend-domain.example.com}"
ORIGIN="${ORIGIN:-https://your-frontend-domain.example.com}"

if [[ "$API_URL" == *"example.com"* ]]; then
	echo -e "${RED}Warning: Using default example URLs. Update API_URL and ORIGIN variables.${NC}\n"
fi

echo -e "${YELLOW}Testing Tarot API Gateway Connection${NC}\n"

# Test 1: OPTIONS request (CORS preflight)
echo -e "${YELLOW}Test 1: OPTIONS /draw (CORS Preflight)${NC}"
echo "URL: $API_URL/draw"
echo "Origin: $ORIGIN"
echo ""

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X OPTIONS "$API_URL/draw" \
	-H "Origin: $ORIGIN" \
	-H "Access-Control-Request-Method: POST" \
	-H "Access-Control-Request-Headers: content-type")

if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 204 ]; then
	echo -e "${GREEN}✓ OPTIONS request successful (HTTP $RESPONSE)${NC}"

	# Show CORS headers
	echo -e "\nCORS Headers:"
	curl -s -X OPTIONS "$API_URL/draw" \
		-H "Origin: $ORIGIN" \
		-H "Access-Control-Request-Method: POST" \
		-H "Access-Control-Request-Headers: content-type" \
		-D - -o /dev/null | grep -i "access-control"
else
	echo -e "${RED}✗ OPTIONS request failed (HTTP $RESPONSE)${NC}"
fi

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Test 2: POST request (actual draw)
echo -e "${YELLOW}Test 2: POST /draw (Actual Draw)${NC}"
echo "URL: $API_URL/draw"
echo "Origin: $ORIGIN"
echo "Payload: 3 cards from Full Deck, Upright only"
echo ""

RESPONSE_CODE=$(curl -s -o /tmp/api_response.json -w "%{http_code}" -X POST "$API_URL/draw" \
	-H "Content-Type: application/json" \
	-H "Origin: $ORIGIN" \
	-d '{
    "deckSize": "Full Deck",
    "deckReverse": "Upright only",
    "numCards": 3
  }')

if [ "$RESPONSE_CODE" -eq 200 ]; then
	echo -e "${GREEN}✓ POST request successful (HTTP $RESPONSE_CODE)${NC}"
	echo -e "\nResponse body:"
	cat /tmp/api_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/api_response.json
else
	echo -e "${RED}✗ POST request failed (HTTP $RESPONSE_CODE)${NC}"
	echo -e "\nResponse body:"
	cat /tmp/api_response.json
fi

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Test 3: Check if Lambda is invoked
echo -e "${YELLOW}Test 3: CloudWatch Logs Check${NC}"
echo "Run this command to check Lambda logs:"
echo -e "${GREEN}aws logs tail /aws/lambda/tarot-backend-draw --since 5m${NC}"

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Test 4: Full verbose request
echo -e "${YELLOW}Test 4: Full Verbose POST Request${NC}"
echo "This shows all headers and connection details:"
echo ""

curl -v POST "$API_URL/draw" \
	-H "Content-Type: application/json" \
	-H "Origin: $ORIGIN" \
	-d '{
    "deckSize": "Full Deck",
    "deckReverse": "Upright only",
    "numCards": 1
  }' 2>&1 | head -50

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
echo -e "${GREEN}Testing complete!${NC}"
echo ""
echo "If all tests passed but frontend still fails, check:"
echo "1. Browser DevTools Console for errors"
echo "2. Browser DevTools Network tab for request details"
echo "3. Verify you're accessing frontend from: $ORIGIN"
