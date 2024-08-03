#!/usr/bin/env bash

# Check if the required environment variables are set
if [[ -z "$DISTRIBUTION_ID" ]]; then
    echo "Error: CloudFront distribution ID environment variable is not set."
    exit 1
fi

# Create CloudFront invalidation
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/images/*"
