for i in `terraform state list | grep $1` ; do 
echo $i
terraform state rm $i -backup=/dev/null -lock=false
done