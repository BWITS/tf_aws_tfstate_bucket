# terraform state buckets

This is an independent terraform module which need be run before any other terraform commands. 

The reason is, we need a s3 bucket to be ready and save terraform tfstate files when [initialize a Terraform configuration](https://www.terraform.io/docs/commands/init.html)

### Features

1. terraform configuration files to create terraform state buckets
2. create source bucket and destination buckets
3. set cross-region replication on the source bucket.

### Set source and destination regions.

Update source and destination regions in `variable.tf`

### S3 bucket name must be globally unique

Currently I use aws account alias name as part of bucket name, you should set postfix to make sure the bucket name is globally unique.

Update bucket postfix name in `variable.tf`

### Import state 

If the tfstate bucket exists, please use below command to import its state. 

    terraform import aws_s3_bucket.bucket <exist_bucket_name>

### Usage

    terraform plan
    terraform apply

### Manually copy the state file to s3 bucket.

After you run `terraform plan` and `terraform apply`, a new state file `terraform.tfstate` is generated, you need manually copy the file to source bucket.

To make sure replicate works, you should see the file has been replicated to bucket `<source_bucket>-destination`

### Reference:

[How to Set Up Cross-Region Replication](http://docs.aws.amazon.com/AmazonS3/latest/dev/crr-how-setup.html)

[initialize a Terraform configuration](https://www.terraform.io/docs/commands/init.html)


