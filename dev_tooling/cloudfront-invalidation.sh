#!/usr/bin/env bash

aws cloudfront create-invalidation --distribution-id E1KSIF4Z1MTT6K --paths "/images/*"
