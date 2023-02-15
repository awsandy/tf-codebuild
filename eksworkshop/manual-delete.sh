acc=$(aws sts get-caller-identity --query Account --output text)
cln=`aws eks list-clusters --query clusters | jq -r '.[]' | grep eks-workshop`
echo $cln
ng=$(aws ec2 describe-nat-gateways --query NatGateways.NatGatewayId --output text)
aws ec2 delete-nat-gateway --nat-gateway-id $ng
for n in `aws eks list-nodegroups --cluster-name $cln --query nodegroups --output text`;do
    echo $n
    aws eks delete-nodegroup --cluster-name $cln --nodegroup-name $n --output text
done
for n in `aws eks list-fargate-profiles --cluster-name $cln --query fargateProfileNames --output text`;do
    echo $n
    if [[ $n != "None" ]];then
        aws eks delete-fargate-profile --cluster-name $cln --fargate-profile-name $n --output text
    fi
done
nn=`aws eks list-nodegroups --cluster-name  $cln | jq -r '.nodegroups[]' | wc -l`
while [[ $nn -ne 0 ]];do
    echo "number nodegroups=$nn"
    sleep 10
    nn=`aws eks list-nodegroups --cluster-name  $cln | jq -r '.nodegroups[]' | wc -l`
done
echo "wait for fargate"
fp=`aws eks list-fargate-profiles --cluster-name  $cln | jq -r '.fargateProfileNames[]' | wc -l`
while [[ $fp -ne 0 ]];do
    echo "Fargate profiles=$fp"
    sleep 10
    fp=`aws eks list-fargate-profiles --cluster-name  $cln | jq -r '.fargateProfileNames[]' | wc -l`
done
echo "delete cluster $cln"
aws eks delete-cluster --name $cln  --output text 
dbn=`aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' | jq -r '.[]' | grep eks-workshop | grep catalog`
echo "delete db instance $dbn"
aws rds delete-db-instance --db-instance-identifier $dbn --skip-final-snapshot --delete-automated-backups --output text
sleep 3
fsid=$(aws efs describe-file-systems  --query FileSystems[0].FileSystemId --output text)
for i in `aws efs describe-mount-targets --file-system-id  $fsid --query MountTargets[].MountTargetId --output text`;do
echo $i
aws efs delete-mount-target --mount-target-id $i
done
lbarn=$(aws elbv2 describe-load-balancers --query LoadBalancers[].LoadBalancerArn --output text)
aws elbv2 delete-load-balancer --load-balancer-arn $lbarn
sleep 10
aws efs delete-file-system --file-system-id  $fsid
aws iam detach-role-policy --role-name eks-workshop-shell-role --policy-arn arn:aws:iam::$acc:policy/eks-workshop-shell-role
aws iam delete-policy --policy-arn arn:aws:iam::$acc:policy/eks-workshop-shell-role 
aws iam delete-role --role-name eks-workshop-shell-role
aws iam detach-role-policy --role-name eks-workshop-grafana-irsa --policy-arn arn:aws:iam::$acc:policy/eks-workshop-grafana-other
aws iam delete-policy --policy-arn arn:aws:iam::$acc:policy/eks-workshop-grafana-other
aws iam detach-role-policy --role-name eks-workshop-grafana-irsa --policy-arn arn:aws:iam::$acc:policy/eks-workshop-grafana
aws iam delete-policy --policy-arn arn:aws:iam::$acc:policy/eks-workshop-grafana
aws iam delete-role --role-name eks-workshop-grafana-irsa
aws codecommit delete-repository --repository-name eks-workshop-gitops
aws ssm delete-parameter --name eks-workshop-gitops-ssh
aws dynamodb delete-table --table-name eks-workshop-carts
aws kms delete-alias --alias-name alias/eks-workshop-cmk
aws kms delete-alias --alias-name alias/eks-workshop
aws iam detach-role-policy --role-name eks-workshop-cluster-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam detach-role-policy --role-name eks-workshop-cluster-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController
aws iam delete-role --role-name eks-workshop-cluster-role
aws iam detach-user-policy --user-name eks-workshop-gitops --policy-arn arn:aws:iam::$acc:policy/eks-workshop-gitops
aws iam delete-policy --policy-arn arn:aws:iam::$acc:policy/eks-workshop-gitops

./cleanup.sh module.cluster.module.eks_blueprints_kubernetes_addons
./cleanup.sh module.cluster.module.eks_blueprints_ack_addons
./cleanup.sh module.cluster.module.eks_blueprints.kubernetes_config_map
./cleanup.sh kubernetes_namespace
./cleanup.sh kubernetes_service
./cleanup.sh module.cluster.module.ec2.helm_release.addon
# all eks-workshop iam roles, policy attachments and policies
# event bridge rules

rm -f t*.backup


