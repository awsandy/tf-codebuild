# get a list of roles
for rn in $(aws iam list-roles --query 'Roles[].RoleName' | jq -r '.[]' | grep eks-workshop); do
    for parn in $(aws iam list-attached-role-policies --role-name $rn --query 'AttachedPolicies[].PolicyArn' | jq -r '.[]'); do
        echo "processing $rn $parn"
        aws iam detach-role-policy --role-name $rn --policy-arn $parn || true
        if [[ $parn == *"eks-workshop*" ]]; then
            aws iam delete-policy --policy-arn $parn || true
        fi
    done
    for ipn in $(aws iam list-instance-profiles-for-role --role-name $rn --query 'InstanceProfiles[]'.InstanceProfileName | jq -r '.[]' | grep eks-workshop); do
        echo $ipn
        aws iam remove-role-from-instance-profile --instance-profile-name $ipn --role-name $rn
        aws iam delete-instance-profile --instance-profile-name $ipn
    done
    echo "Deleting role $rn"
    aws iam delete-role --role-name $rn || true
done
# policy delete
for pn in $(aws iam list-policies | jq '.Policies[] | select(.PolicyName | contains("eks-workshop"))' | jq -r .Arn | grep eks-workshop); do
    echo "Delete policy $pn"
    aws iam delete-policy --policy-arn $pn
done
