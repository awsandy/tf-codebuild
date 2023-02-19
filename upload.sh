aws s3 cp eksworkshop/buildspec.yml s3://event-engine-eu-west-1/eksworkshop/buildspec.yml
aws s3 cp eksworkshop/ee/buildspec.yml s3://event-engine-eu-west-1/eksworkshop/ee/buildspec.yml
aws s3 cp eksworkshop/ws/buildspec.yml s3://event-engine-eu-west-1/eksworkshop/ws/buildspec.yml
#aws s3 cp eksworkshop/cloud9.tf s3://event-engine-eu-west-1/eksworkshop/cloud9.tf
aws s3 cp eksworkshop/cloud9.tf s3://event-engine-eu-west-1/eksworkshop/ee/cloud9.tf
aws s3 cp eksworkshop/cloud9.tf s3://event-engine-eu-west-1/eksworkshop/ws/cloud9.tf
#
aws s3 cp eksworkshop/cleanup.sh s3://event-engine-eu-west-1/eksworkshop/cleanup.sh
aws s3 cp eksworkshop/manual-delete.sh s3://event-engine-eu-west-1/eksworkshop/manual-delete.sh
aws s3 cp eksworkshop/del-iam.sh s3://event-engine-eu-west-1/eksworkshop/del-iam.sh
# test stuff
aws s3 cp test/buildspec.yml s3://event-engine-eu-west-1/tf-codebuild1/buildspec.yml
aws s3 cp test/vpc-test.tf s3://event-engine-eu-west-1/tf-codebuild1/vpc-test.tf