# Comfy Cloud – Hoodie Pipeline (Module 1)

Here are some instructions to get you running a dev pipeline so you can follow the course demo.  

---

## Prerequisites

| Tool | Version |
|------|---------|
| **AWS CLI** | ≥ 2.13 |
| **eksctl** | ≥ 0.161 |
| **kubectl** | ≥ 1.29 |

If you run the lab in AWS CloudShell, you'll need to install eksctl (steps below).
You’ll also need an AWS account with permissions to create EKS, ECR, IAM roles, and CodeConnections.

---

## One-time bootstrap (~10 min)

1. **Clone the repo & switch into the comfy-cloud-pipeline directory**

   ```bash
   git clone https://github.com/MichaelCassidyPS/comfy-cloud-pipeline.git || true
   cd comfy-cloud-pipeline


2. **Install `eksctl`**

~~~bash
# 1) Download and unpack the latest eksctl
curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp

# 2) Move into your persistent home directory
mkdir -p "$HOME/bin"
mv /tmp/eksctl "$HOME/bin/eksctl"

# 3) Ensure ~/bin is in your login shell PATH
grep -qxF 'export PATH=$HOME/bin:$PATH' ~/.bash_profile \
  || echo 'export PATH=$HOME/bin:$PATH' >> ~/.bash_profile

# 4) Export the new PATH in the current shell
export PATH="$HOME/bin:$PATH"

# 5) Verify installation
eksctl version
~~~


3. **Create the EKS cluster**

   ~~~bash
   eksctl create cluster \
     --name dev-eks \
     --region us-east-1 \
     --nodes 2 \
     --node-type t3.medium \
     --vpc-nat-mode=Disable \
     --node-private-networking=false
   ~~~

4. **Create a private ECR repo**

   ~~~bash
   aws ecr create-repository --repository-name hoodie-api
   ~~~
   After running the above command, press **q** to quit the pager and return to the shell.

5. **Create two IAM roles**

~~~bash
########################################
# 1) Turn off the interactive pager
########################################
export AWS_PAGER=""

########################################
# 2) Build role for CodeBuild
########################################
aws iam create-role --role-name ComfyBuildRole \
  --assume-role-policy-document \
'{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"codebuild.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

aws iam attach-role-policy --role-name ComfyBuildRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

########################################
# 3) Pipeline role for CodePipeline
########################################
aws iam create-role --role-name ComfyPipelineRole \
  --assume-role-policy-document \
'{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"codepipeline.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

aws iam attach-role-policy --role-name ComfyPipelineRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

~~~

All five commands are safe to rerun if you need to.

---

## Deploy the services to EKS

Apply the manifests in **k8s/** (added to this repo):

~~~bash
kubectl apply -f k8s/checkout-deployment.yaml
kubectl apply -f k8s/payment-deployment.yaml
kubectl apply -f k8s/deployment.yaml

~~~
> **Run each command on its own line in CloudShell.**


---

## Ready for the demo

With the cluster, repo, IAM roles, GitHub connection, and services in place you can jump into the video:

* Create the **CodeBuild** project `hoodie-build`.  
* Let the build push the image to **ECR**.  
* Patch the image URI into the Deployment.  
* Preview the service in CloudShell.


