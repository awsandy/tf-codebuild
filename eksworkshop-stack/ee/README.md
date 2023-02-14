For event engine.

Blueprint name: eksworkshop2
Owner arn: arn:aws:iam::${AWS::AccountId}:assumed-role/TeamRole/MasterKey


This stackset:
sets up codebuild project - that takes buildspec.yml from

event-engine-eu-west-1/eksworkshop/

The code build project is started by a lambda - triggered via a custom resource


The buildspec.yml:

Includes:

git clone https://github.com/aws-samples/eks-workshop-v2.git
cd eks-workshop-v2/terraform
cp variables.tf variables.tf.sav
cp ../../variables.tf cp ../../variables.tf




------

variables.tf

data.aws_caller_identity.current.account_id




