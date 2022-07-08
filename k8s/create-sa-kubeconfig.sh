#
# Create Admin KubeConfig file For Lens usage
# Paste your AWS creds and run below snippet to generate kubeconfig file
#
region_code=us-east-1
cluster_name=YOURCLUSTERNAME
account_id=$(aws sts get-caller-identity --query 'Account' --output text)

echo $region_code
echo $cluster_name
echo $account_id
	
cluster_endpoint=$(aws eks describe-cluster \
    --region $region_code \
    --name $cluster_name \
    --query "cluster.endpoint" \
    --output text)
echo $cluster_endpoint

certificate_data=$(aws eks describe-cluster \
    --region $region_code \
    --name $cluster_name \
    --query "cluster.certificateAuthority.data" \
    --output text)
echo $certificate_data

SERVICE_ACCOUNT=kubeconfig-sa-$cluster_name
kubectl create serviceaccount $SERVICE_ACCOUNT
kubectl create clusterrolebinding $SERVICE_ACCOUNT    --clusterrole=cluster-admin --serviceaccount=default:$SERVICE_ACCOUNT
TOKEN_NAME=$(kubectl get sa $SERVICE_ACCOUNT -o jsonpath='{.secrets[0].name}')
TOKEN_VALUE=$(kubectl get secret "${TOKEN_NAME}" -o jsonpath='{.data.token}' | base64 -d)

read -r -d '' KUBECONFIG <<EOF
apiVersion: v1
preferences: {}
kind: Config

clusters:
- cluster:
    certificate-authority-data: $certificate_data
    server: $cluster_endpoint
  name: $SERVICE_ACCOUNT

contexts:
- context:
    namespace: default
    cluster: $SERVICE_ACCOUNT
    user: $SERVICE_ACCOUNT
  name: $SERVICE_ACCOUNT
  
current-context: $SERVICE_ACCOUNT

users:
- name: $SERVICE_ACCOUNT
  user:
    token: $TOKEN_VALUE
EOF
echo "${KUBECONFIG}" 
