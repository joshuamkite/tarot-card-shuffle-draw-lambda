#!/usr/bin/env bash
# CloudFront cache invalidation utility
# Invalidates the /images/* path to force cache refresh after uploading new card images
#
# Usage: DISTRIBUTION_ID=your-distribution-id ./cloudfront-invalidation.sh

# Check if the required environment variables are set
if [[ -z "$DISTRIBUTION_ID" ]]; then
	echo "Error: CloudFront distribution ID environment variable is not set."
	echo "Usage: DISTRIBUTION_ID=your-distribution-id ./cloudfront-invalidation.sh"
	exit 1
fi

# Create CloudFront invalidation
echo "Creating CloudFront invalidation for /images/* on distribution: $DISTRIBUTION_ID"
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/images/*"
