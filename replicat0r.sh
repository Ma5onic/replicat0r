#!/bin/bash
#---------------------------------------------------------------------------------------------------#
# KMS Key Should be on the same Region as Destination
# Ideally on a seperate account, with trust relationships giving access to the key to encrypt. (RO)
#---------------------------------------------------------------------------------------------------#
# Include Config Variables
# Remember to edit the setup.conf file with your own environment details
#-------------------#

source ./conf/setup.conf

VAULTD="aws-vault exec ${DPROFILE} --"
VAULTS="aws-vault exec ${SPROFILE} --"

#-------------------#
# Script
#--------#

#echo "Creating source s3 bucket textfile"
#$VAULTS aws s3 ls | cut -d' ' -f3 | grep -v us-west-2 | grep -v test | grep -v area51 | sort -u > ./publish/s3_src.txt

echo "Creating buckets in destination..."
for bucket in $(cat ./publish/s3_src.txt);
do
    $VAULTS aws s3api put-bucket-versioning --bucket ${bucket} --versioning-configuration Status=Enabled;
    echo "Creating s3 bucket in destination: ${bucket}"
    $VAULTD aws s3 mb s3://${bucket}-replica --region ${DSTREGION};
    $VAULTD aws s3api put-bucket-versioning --bucket ${bucket}-replica --versioning-configuration Status=Enabled;


    echo "Applying bucket policy in destination..."

    echo "Applying policy to bucket: ${bucket}"
    sed "s/BUCKET/$bucket/g; s/XACCOUNTX/$SRCACCOUNTID/g;" ./conf/dst_policy.txt > ./publish/dst_policy.json;
    
    $VAULTD aws s3api put-bucket-policy --bucket ${bucket}-replica --policy file://publish/dst_policy.json --region ${SRCREGION};

    echo "Creating Trust roles: "

    $VAULTS aws iam create-role --role-name crrRole-${bucket} --assume-role-policy-document file://publish/src_trust.json;

    echo "Creating policy(s) on source..."

    sed "s/BUCKET/$bucket/g; s/XSRCREGIONX/$SRCREGION/g; s/XDSTREGIONX/$DSTREGION/g;" ./conf/src_policy.txt > ./publish/src_policy.json;
    
    ARN=$($VAULTS aws iam create-policy --policy-name crrPolicy-${bucket} --policy-document file://publish/src_policy.json --output text | cut -f2 -d$'\t');

    $VAULTS aws iam attach-role-policy --role-name crrRole-${bucket} --policy-arn ${ARN};

    echo "Setup s3 replication on source..."

    sed "s/BUCKET/$bucket/g; s/XACCOUNTX/$SRCACCOUNTID/g; s/XROLEX/crrRole-${bucket}/g; s/DACCOUNTD/$DSTACCOUNTID/g;" ./conf/src_replica.txt > ./publish/src_replica.json;

    $VAULTS aws s3api put-bucket-replication --bucket ${bucket} --replication-configuration file://publish/src_replica.json;

    echo "Finished *-[${bucket}]-*"
done

# Confirm replication rule:
#$VAULTS aws s3api get-bucket-replication --bucket ${bucket}
