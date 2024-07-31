#!/usr/bin/env bash

aws cloudfront create-invalidation --distribution-id EB8KMAZPP34CI --paths "/images/*"
