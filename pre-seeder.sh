#!/bin/bash

# Pre-Seed s3 buckets for Replication.

for bucket in $(cat ./publish/s3_src.txt);
do
    echo $bucket
    aws s3 sync s3://$bucket/ s3://${bucket}-replica/ --profile backup;
done
