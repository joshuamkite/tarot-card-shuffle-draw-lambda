#!/bin/env bash

# Set your API ID and function name
# API_ID=""
FUNCTION_NAME="TarotDrawFunction"

echo "Gathering API Gateway and Lambda information..."

echo -e "\n1. API Details:"
aws apigateway get-rest-api --rest-api-id $API_ID

echo -e "\n2. API Resources:"
RESOURCES=$(aws apigateway get-resources --rest-api-id $API_ID)
echo "$RESOURCES"

echo -e "\n3. Methods and Integrations for each Resource:"
echo "$RESOURCES" | jq -r '.items[] | .id' | while read -r RESOURCE_ID; do
    echo -e "\nResource ID: $RESOURCE_ID"
    for METHOD in GET POST OPTIONS; do
        echo -e "\n  $METHOD Method:"
        aws apigateway get-method --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method $METHOD 2>/dev/null || echo "    Not configured"
        echo -e "\n  $METHOD Integration:"
        aws apigateway get-integration --rest-api-id $API_ID --resource-id $RESOURCE_ID --http-method $METHOD 2>/dev/null || echo "    Not configured"
    done
done

echo -e "\n4. API Deployments:"
aws apigateway get-deployments --rest-api-id $API_ID

echo -e "\n5. 'Prod' Stage Details:"
aws apigateway get-stage --rest-api-id $API_ID --stage-name Prod

echo -e "\n6. Lambda Function Policy:"
aws lambda get-policy --function-name $FUNCTION_NAME 2>/dev/null || echo "No resource-based policy found for $FUNCTION_NAME"

echo -e "\nDone gathering information."
