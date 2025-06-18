# comfy-cloud-pipeline
# Comfy Cloud – Hoodie Pipeline (Module 1)

Minimal instructions to get you from **zero** to a running dev pipeline so you can follow the course demo.  
Nothing extra—just the pieces the video asks for.

---

## Prerequisites

| Tool | Version |
|------|---------|
| **AWS CLI** | 
| **eksctl** | 
| **kubectl** | 

You’ll also need an AWS account with permissions to create EKS, ECR, IAM roles, and CodeConnections.

---

## One-time bootstrap (~5 min)

1. **Create the EKS cluster**

   ~~~bash
   eksctl create cluster --name dev-eks --region us-east-1 \
     --managed --nodes 2 --node-type t3.medium
   ~~~

2. **Create a private ECR repo**

   ~~~bash
   aws ecr create-repository --repository-name hoodie-api
   ~~~

3. **Create two IAM roles**

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

4. **Connect your fork via CodeConnections**

   ~~~bash
   aws codeconnections create-connection \
     --provider-type GitHub \
     --connection-name HoodiePipelineConnection
   ~~~

All four commands are safe to rerun if you need to.

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

