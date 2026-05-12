STUDENT_NAME="rainer"

CLUSTER_NAME="spot-eks-lab-${STUDENT_NAME}"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_NAME="AmazonEKS_EBS_CSI_DriverRole_${STUDENT_NAME}"

# Step 1: Create the IAM role
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name $ROLE_NAME

# Step 2: Install the EBS CSI driver addon
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME} \
  --force
