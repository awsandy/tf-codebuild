# tags: created-by : eks-workshop-v2
acc=$(aws sts get-caller-identity --query Account --output text)
# event bridge rules 
for ebr in $(aws events list-rules --query 'Rules[].Name' | jq -r '.[]' | grep eks-workshop); do
    echo $ebr
    for ebt in $(aws events list-targets-by-rule --rule $ebr --query 'Targets[].Id' | jq -r '.[]' ); do
        aws events remove-targets --rule $ebr --ids $ebt
    done
    aws events delete-rule --name $ebr
done
cln=$(aws eks list-clusters --query clusters | jq -r '.[]' | grep eks-workshop)
echo $cln
if [[ $cln != "" ]]; then
    ng=$(aws ec2 describe-nat-gateways --query NatGateways.NatGatewayId --output text)
    aws ec2 delete-nat-gateway --nat-gateway-id $ng
    for n in $(aws eks list-nodegroups --cluster-name $cln --query nodegroups --output text); do
        echo $n
        aws eks delete-nodegroup --cluster-name $cln --nodegroup-name $n --output text
    done
    for n in $(aws eks list-fargate-profiles --cluster-name $cln --query fargateProfileNames --output text); do
        echo $n
        if [[ $n != "None" ]]; then
            aws eks delete-fargate-profile --cluster-name $cln --fargate-profile-name $n --output text
        fi
    done
    nn=$(aws eks list-nodegroups --cluster-name $cln | jq -r '.nodegroups[]' | wc -l)
    while [[ $nn -ne 0 ]]; do
        echo "number nodegroups=$nn"
        sleep 10
        nn=$(aws eks list-nodegroups --cluster-name $cln | jq -r '.nodegroups[]' | wc -l)
    done
    echo "wait for fargate"
    fp=$(aws eks list-fargate-profiles --cluster-name $cln | jq -r '.fargateProfileNames[]' | wc -l)
    while [[ $fp -ne 0 ]]; do
        echo "Fargate profiles=$fp"
        sleep 10
        fp=$(aws eks list-fargate-profiles --cluster-name $cln | jq -r '.fargateProfileNames[]' | wc -l)
    done
    echo "delete cluster $cln"
    aws eks delete-cluster --name $cln --output text
fi
dbn=$(aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' | jq -r '.[]' | grep eks-workshop | grep catalog)
if [[ $dbn != "" ]]; then
    echo "delete db instance $dbn"
    aws rds delete-db-instance --db-instance-identifier $dbn --skip-final-snapshot --delete-automated-backups --output text
    sleep 3
fi
fsid=$(aws efs describe-file-systems --query 'FileSystems[0].FileSystemId' --output text)
for i in $(aws efs describe-mount-targets --file-system-id $fsid --query MountTargets[].MountTargetId --output text); do
    echo $i
    aws efs delete-mount-target --mount-target-id $i
done
lbarn=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text)
if [[ $lbarn != "" ]]; then
    aws elbv2 delete-load-balancer --load-balancer-arn $lbarn
    sleep 10
fi
./del-iam.sh
aws efs delete-file-system --file-system-id $fsid
aws codecommit delete-repository --repository-name eks-workshop-gitops
aws ssm delete-parameter --name eks-workshop-gitops-ssh
aws dynamodb delete-table --table-name eks-workshop-carts
aws kms delete-alias --alias-name alias/eks-workshop-cmk
aws kms delete-alias --alias-name alias/eks-workshop

./cleanup.sh module.cluster.module.eks_blueprints_kubernetes_addons 2>/dev/null
./cleanup.sh module.cluster.module.eks_blueprints_ack_addons 2>/dev/null
./cleanup.sh module.cluster.module.eks_blueprints.kubernetes_config_map 2>/dev/null
./cleanup.sh kubernetes_namespace 2>/dev/null
./cleanup.sh kubernetes_service 2>/dev/null
./cleanup.sh module.cluster.module.ec2.helm_release.addon 2>/dev/null

# SQS node_termination_handler

rm -f t*.backup
# oidc by tags   created-by : eks-workshop-v2

# nat gateway
