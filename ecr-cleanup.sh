#!/bin/bash

# ECR Repository Name
REPO_NAME="your-ecr-repo-name"

# Pattern for image names
IMAGE_PATTERN="*-TC*"

# Date range
START_DATE="2023-01-01T00:00:00Z"
END_DATE="2023-09-01T23:59:59Z"

# Get list of images in the repository
image_list=$(aws ecr describe-images --repository-name $REPO_NAME --query 'imageDetails[?(@.imageTags)]' --output json | jq -r '.[] | select(.imageTags | length > 0) | select(.imageTags[] | test("'"$IMAGE_PATTERN"'")) | select(.imagePushedAt >= "'"$START_DATE"'" and .imagePushedAt <= "'"$END_DATE"'") | .imageDigest')

# Delete images
for image_digest in $image_list; do
    echo "Deleting image: $image_digest"
    aws ecr batch-delete-image --repository-name $REPO_NAME --image-ids imageDigest=$image_digest
done
