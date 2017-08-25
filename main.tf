provider "aws" {
  version = "~> 0.1"
  region  = "${var.source_region}"
}

provider "template" {
  version = "~> 0.1"
}

data "aws_iam_account_alias" "current" {}

provider "aws" {
  alias  = "destination"
  region = "${var.dest_region}"
}

resource "aws_iam_role" "replication" {
  name = "tf-iam-role-replication-configuration"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "tf-iam-role-policy-replication-configuration"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.destination.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "tf-iam-role-attachment-replication-configuration"
  roles      = ["${aws_iam_role.replication.name}"]
  policy_arn = "${aws_iam_policy.replication.arn}"
}

resource "aws_s3_bucket" "destination" {
  provider = "aws.destination"
  bucket   = "${data.aws_iam_account_alias.current.account_alias}-${var.postfix}-destination"
  region   = "${var.dest_region}"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${data.aws_iam_account_alias.current.account_alias}-${var.postfix}"
  acl    = "private"
  region = "${var.source_region}"

  versioning {
    enabled = true
  }

  replication_configuration {
    role = "${aws_iam_role.replication.arn}"

    rules {
      id     = "replica_configuration"
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.destination.arn}"
        storage_class = "STANDARD"
      }
    }
  }
}
