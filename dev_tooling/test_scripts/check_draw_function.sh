#!/bin/bash
# API Gateway v2 (HTTP API) inspection script
# Checks routes, integrations, and tests the /draw endpoint

# Set your API ID and Stage Name (update these values for your deployment)
API_ID="${API_ID:-YOUR_API_ID_HERE}"
STAGE_NAME="\$default"
LAMBDA_FUNCTION_NAME="DrawFunction"
AWS_REGION="${AWS_REGION:-eu-west-2}"
API_URL="https://${API_ID}.execute-api.${AWS_REGION}.amazonaws.com/${STAGE_NAME}/draw"

if [ "$API_ID" = "YOUR_API_ID_HERE" ]; then
	echo "Error: Please set API_ID environment variable or update the script"
	echo "Usage: API_ID=your-api-id ./check_draw_function.sh"
	exit 1
fi

# List API Gateways
echo "Listing API Gateways..."
aws apigatewayv2 get-apis

# List Routes for your API
echo "Listing Routes for API ID: ${API_ID}..."
aws apigatewayv2 get-routes --api-id ${API_ID}

# Get details of the specific POST /draw route
ROUTE_ID=$(aws apigatewayv2 get-routes --api-id ${API_ID} --query 'Items[?RouteKey==`POST /draw`].RouteId' --output text)
echo "Route ID for POST /draw: ${ROUTE_ID}"

echo "Getting Route Details for Route ID: ${ROUTE_ID}..."
aws apigatewayv2 get-route --api-id ${API_ID} --route-id ${ROUTE_ID}

# Get the integration details for the POST /draw route
INTEGRATION_ID=$(aws apigatewayv2 get-route --api-id ${API_ID} --route-id ${ROUTE_ID} --query 'Target' --output text | cut -d'/' -f2)
echo "Integration ID for POST /draw: ${INTEGRATION_ID}"

echo "Getting Integration Details for Integration ID: ${INTEGRATION_ID}..."
aws apigatewayv2 get-integration --api-id ${API_ID} --integration-id ${INTEGRATION_ID}

# Test the POST /draw endpoint using curl
echo "Testing POST /draw endpoint..."
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "deckSize=Full+Deck&deckReverse=Upright+and+reversed&numCards=8" ${API_URL}

echo "All checks complete."
