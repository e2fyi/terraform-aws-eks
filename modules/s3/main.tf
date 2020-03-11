resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket

  acl = var.acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_id
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging
    content {
      target_bucket = logging.key
      target_prefix = logging.value
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.folder_to_expiration_days
    content {
      id      = lifecycle_rule.key
      prefix  = "${lifecycle_rule.key}/"
      enabled = true

      expiration {
        days = lifecycle_rule.value
      }
    }
  }

  tags = merge({ Name = var.bucket }, var.tags)
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket.json
}

data aws_iam_policy_document "bucket" {
  source_json = var.bucket_policy

  statement {
    sid    = "ManualBucketDelete"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteBucket"
    ]
    resources = [
      aws_s3_bucket.bucket.arn
    ]
  }

  dynamic "statement" {
    for_each = var.readonly_access

    content {
      sid    = "ReadOnly"
      effect = "Allow"
      actions = [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
      ]
      principals {
        type        = "AWS"
        identifiers = statement.value
      }
      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/${statement.key}",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.readwrite_access

    content {
      sid    = "ReadWrite"
      effect = "Allow"
      actions = [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
      ]
      principals {
        type        = "AWS"
        identifiers = statement.value
      }
      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/${statement.key}",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.whitelisted_ips

    content {
      sid    = "Kubeflow"
      effect = "Allow"
      actions = [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
      ]
      principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
      condition {
        test     = "IpAddress"
        variable = "aws:SourceIp"
        values   = statement.value
      }

      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/${statement.key}/*",
      ]

    }
  }
}
