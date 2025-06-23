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

## One-time bootstrap (~5 min)

1. **Install `eksctl` (only if `eksctl version` returns “command not found”)**

~~~bash
# a. Choose architecture 
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH    # prints Linux_amd64

# b. Fetch the current release tarball from GitHub
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"   # :contentReference[oaicite:1]{index=1}

# c. Unpack to a temp folder
tar -xzf eksctl_${PLATFORM}.tar.gz -C /tmp
rm eksctl_${PLATFORM}.tar.gz

# d. Move it into your personal bin directory (persists between sessions)
mkdir -p $HOME/bin
mv /tmp/eksctl $HOME/bin/

# e. Add that directory to PATH (once)
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# verify
eksctl version
~~~


2. **Create the EKS cluster**

   ~~~bash
   eksctl create cluster --name dev-eks --region us-east-1 \
     --managed --nodes 2 --node-type t3.medium
   ~~~

3. **Create a private ECR repo**

   ~~~bash
   aws ecr create-repository --repository-name hoodie-api
   ~~~
   After running the above command, press **q** to quit the pager and return to the shell.

4. **Create two IAM roles**

   *Build role* and *Pipeline role* both use AdministratorAccess (simplest for the course).

   ~~~bash
   aws iam create-role --role-name ComfyBuildRole \
     --assume-role-policy-document file://iam/trust-build.json
   aws iam attach-role-policy --role-name ComfyBuildRole \
     --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

   aws iam create-role --role-name ComfyPipelineRole \
     --assume-role-policy-document file://iam/trust-pipeline.json
   aws iam attach-role-policy --role-name ComfyPipelineRole \
     --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
   ~~~

5. **Connect your fork via CodeConnections**

   ~~~bash
   aws codeconnections create-connection \
     --provider-type GitHub \
     --connection-name HoodiePipelineConnection
   ~~~

All five commands are safe to rerun if you need to.

---

## Deploy the services to EKS

Apply the manifests in **k8s/** (added to this repo):

~~~bash
kubectl apply -f k8s/checkout-deployment.yaml
kubectl apply -f k8s/payment-deployment.yaml
~~~

Both Deployments start **2 replicas** and expose ClusterIP services.

---

## Ready for the demo

With the cluster, repo, IAM roles, GitHub connection, and services in place you can jump into the video:

* Create the **CodeBuild** project `hoodie-build`.  
* Let the build push the image to **ECR**.  
* Patch the image URI into the Deployment.  
* Forward port 8000 and open **http://localhost:8000** to see **“Hello, Hoodie!”**.


