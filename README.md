#replicat0r
# Ermis Catevatis - Skio Music

This project is a quick automation to build replication policies between two accounts, source and destination.
It will build the proper bucket policies and s3 iam policies for replication to work.

You will need to build a setup.conf with variables that are missing, read the bash script and fill them in appropriately.
setup.conf is sourced in replicat0r.sh.

If you have any questions feel free to ask Ermis


# Requirements

aws-vault use is assumed, setup your profile names in the setup.conf for Source / Destination

I had built a version using KMS, so ignore any comments, I decided after building it to remove KMS encryption from our data.
The backup account is secured well, and in case of issue with prod's s3 data, we don't want to sit there and decrypt terabytes of data in our Backup s3 buckets.
I decided on a balance of convenience and security because the Backup account is never used by anyone.
