#replicat0r
# Ermis Catevatis - Skio Music

This project is a quick automation to build replication policies between two accounts, source and destination.
It will build the proper bucket policies and s3 iam policies for replication to work.

You will need to build a setup.conf with variables that are missing, read the bash script and fill them in appropriately.
setup.conf is sourced in replicat0r.sh.

If you have any questions feel free to ask Ermis


# Requirements

aws-vault use is assumed, setup your profile names in the setup.conf for Source / Destination

I had built a version using KMS, so ignore any comments, I decided after building it to remove KMS encryption from this project, I will fork it and do a KMS version.

```./conf/``` Directory is just Templates
```./publish/``` Directory are the generated JSON files from these Templates.

If you need to make changes to the json files, and your changes keep getting over written, adjust the Template version.

```./conf/setup.conf``` This is the variable file sourced into replicat0r at startup. It's structure is like this:

```
SRCREGION="us-west-2"
DSTREGION="us-east-1"
SRCACCOUNTID=""
DSTACCOUNTID=""
SPROFILE=""
DPROFILE=""
```

Other then that, this just works pretty seemlessly, please note the buckets need to be in different regions for replication to work.

## Pre-Seeder
After you run replicat0r and it works (test it by placing a temporary text file in source account, if it arrives automatically on the destination bucket, TA DA!)

But replication does not copy over existing files... So here is the quick and dirty way I did it, and trust me I looked into other methods but altering s3 bucket policy is defacto..

Make an account on Destination account, give it R/W access to s3 buckets on Destination account.

Add a bucket policy similar to the one below, or append the two statements onto your existing bucket policy on the Source account temporarily:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PreSeed Temp",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::[DST ACCOUNT ID]:root"
            },
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::[SOURCE BUCKET]",
                "arn:aws:s3:::[SOURCE BUCKET]/*"
            ]
        }
    ]
}
```


Now you can run pre-seeder.sh using the same s3_src.txt file you used with replicat0r and it will automatically seed in all of your existing source bucket data into your destination bucket.
Remember to remove these temporary bucket policies from the SOURCE buckets when you are done seeding. They are secure enough describing a Principal account (or decrease the vector with a user ARN if your backup account has users on it)

