#!/bin/bash

# Need to set AWS_REGION
if [ -z "$AWS_REGION" ]; then
	echo "AWS_REGION is not set. Please set the AWS_REGION environment variable."
	exit 1
fi

# Variables
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="tarot-images-bucket-${ACCOUNT_ID}-${AWS_REGION}"

# Directory containing the images
IMAGE_DIR="../draw/static/images"

# Upload images to S3 bucket
aws s3 sync $IMAGE_DIR s3://$BUCKET_NAME/images/ # --acl private

# Verify the upload
if [ $? -eq 0 ]; then
	echo "Images uploaded successfully to s3://$BUCKET_NAME/images/"
else
	echo "Failed to upload images to s3://$BUCKET_NAME/images/"
	exit 1
fi
