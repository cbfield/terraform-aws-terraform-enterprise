{
  "Version": "2012-10-17",
  "Id": "PutObjPolicy",
  "Statement": [
      {
          "Sid": "Deny Unencrypted Uploads",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": [
              "arn:aws:s3:::${bucket}*"
          ],
          "Condition": {
              "Null": {
                  "s3:x-amz-server-side-encryption": "true"
              }
          }
      },
      {
          "Sid": "Deny AES256",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": [
              "arn:aws:s3:::${bucket}*"
          ],
          "Condition": {
              "StringEquals": {
                  "s3:x-amz-server-side-encryption": "AES256"
              }
          }
      },
      {
          "Sid": "KMS Key Required",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": [
              "arn:aws:s3:::${bucket}*"
          ],
          "Condition": {
              "StringNotLikeIfExists": {
                  "s3:x-amz-server-side-encryption-aws-kms-key-id": "${kms_key}"
              }
          }
      }
  ]
}
