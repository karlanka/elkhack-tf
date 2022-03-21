#!/usr/bin/bash

timestamp=$(date "+%Y%m%d_%H%M%S")
aws s3 cp data/data_demo.json s3://demo-elkhack-stage/data_demo_$timestamp.json --profile antondev
