# comfy-cloud-pipeline
Comfy Cloud Hoodie Pipeline

In this lab you’ll push a Docker image to **Amazon ECR** with **AWS CodeBuild** and deploy it to a tiny **Amazon EKS** dev cluster.  
All steps run in the **default VPC** so setup is only four commands and one GitHub-App click.

---

## 1  One-Time Prep (< 15 min)

| Step | Command | Why |
|------|---------|-----|
| 1 Clone or fork the repo | `git clone https://github.com/<YOUR-HANDLE>/comfy-cloud-pipeline.git` | Gives the GitHub App a repo to read |
| 2 Create dev EKS cluster | `eksctl create cluster --name dev-eks --nodes 2 --node-type t3.small --region $AWS_REGION` | Fast starter cluster :contentReference[oaicite:0]{index=0} |
| 3 Create ECR repo | `aws ecr create-repository --repository-name hoodie-api` | Target for the image push :contentReference[oaicite:1]{index=1} |
| 4 Make two IAM roles in the console | **ComfyBuildRole** → paste *Policy A*<br>**ComfyPipelineRole** → paste *Policy B* | Least-privilege roles (inline policy wizard) :contentReference[oaicite:2]{index=2} |
| 5 Register a GitHub App connection | Console → *CodeConnections* → *Create connection* → GitHub | Secure, token-less access via the AWS Connector App :contentReference[oaicite:3]{index=3} |

### Policy A (ComfyBuildRole)

{
  "Version":"2012-10-17",
  "Statement":[
    {"Effect":"Allow","Action":[
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ],"Resource":"*"},
    {"Effect":"Allow","Action":"s3:PutObject","Resource":"arn:aws:s3:::comfy-build-logs/*"}
  ]
}

### Policy B (ComfyBuildRole)

{
  "Version":"2012-10-17",
  "Statement":[
    {"Effect":"Allow","Action":"ecr:BatchGetImage","Resource":"*"},
    {"Effect":"Allow","Action":[
      "eks:DescribeCluster",
      "eks:DescribeNodegroup"
    ],"Resource":"*"}
  ]
}

## 2 Demo Guide (follow the video)
Create CodeBuild project

Source → GitHub App connection (main)

Environment → aws/codebuild/standard:7.0 (privileged) 
docs.aws.amazon.com

Role → ComfyBuildRole

Start build → watch it push latest to ECR.

kubectl apply -f k8s/deployment.yaml (CodeBuild already patched <IMAGE_URI> in post_build).

Check roll-out: kubectl get pods -w then kubectl logs <pod> – you’ll see “Hello, Hoodie!”.

##  Clean Up
eksctl delete cluster --name dev-eks
aws ecr delete-repository --repository-name hoodie-api --force

