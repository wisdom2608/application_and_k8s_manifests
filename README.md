# This project is to build and push docker image to dockerhub, update kubernetes manifest file with the latest image tag, and commit the changes to the same (update the) repository
# Step 1: Create a github repository  for your application  source code
  - N=Repository name: `application`
  - Inside `application` repository:

     -  create a `.github/workflows/main.yml` directry.
     -  create another directry `manifests`
     -  inside of `manifests`, create `service.yml` and `deploy.yml` files.

`deploy.yml`
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: your_dokerub_username/your_image_name:2025-04-22-16-11 # Here is the image tag we want to updating whenever there are new changes in our  application source code
          imagePullPolicy: Always
          ports:
            - containerPort: 80
```

# Step 2: Build and push docker image to dockerhub
  - Here is the workflow file.

```bash
name: Docker Image Build and Push To Docker Hub

on:
  push:
    branches:
      - main
    paths:
      - '**/*' # This will trigger whenever there are changes in any file in the repository
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker
        uses: docker/setup-buildx-action@v2

      - name: Login To Dockerhub With Dockerhub Credentials
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Tag Docker Image With Current Date and Timestamp
        id: date_time
        run: echo "timestamp=$(date +'%Y-%m-%d-%H-%M')" >> $GITHUB_OUTPUT
      
      - name: Build Docker Image
        run: |
          docker build -t your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }} . 
      
      - name: Push Docker Image To Dockerhub Repository
        run: |
          docker push your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }}

```

# Step 3: We need to update the k8s manifest(deploy.yml) file with the latest image tag after the image is built and pushed to dockerhub successfully.

- In the same workflow file, we add the steps for the image tag update.
**There  two ways to update the image tag in the Kubernetes manifests(deploy.yml) file**:

- a) *Using `sed` command to find and replace the image tag in the Kubernetes manifest file direclty*:

```bash
# UPdate the K8s Manifest Files

        # View the old k8s manifest (optional)
      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      # Update the image tag in the Kubernetes manifest file (Required)
      - name: Update Manifests with New Image Tag
        run: |
            sed -i "s|image: wisdom2608/wisdomtech:.*|image: wisdom2608/wisdomtech:${{  steps.date_time.outputs.timestamp }}|g" manifests/deploy.yml

      # View the new k8s manifest after update (optional)
      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml

```
- b) *Using `find` command to find and replace the image tag in the Kubernetes manifests file*:

```bash
# UPdate the K8s Manifest Files

        # View the old k8s manifest before update(optional)
      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      # Update the image tag in the Kubernetes manifest file (Required)
      - name:  Update image tag in manifests
        run: |
          find ./manifests -type f -name "deploy.yml" -exec sed -i "s|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:.*|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:${{ steps.date_time.outputs.timestamp }}|g" {} +

      # Vieww the new k8s manifest after update (optional)
      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml
```
# So, choose any of the workflow files below for your project, but not both.

- A) *Workflow file using `sed` command to find and replace the image tag in the Kubernetes manifest file direclty*:

```bash
name: Docker Image Build and Push To Docker Hub

on:
  push:
    branches:
      - main
    paths:
      - '**/*' # This will trigger whenever there are changes in any file in the repository
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker
        uses: docker/setup-buildx-action@v2

      - name: Login To Dockerhub With Dockerhub Credentials
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Tag Docker Image With Current Date and Timestamp
        id: date_time
        run: echo "timestamp=$(date +'%Y-%m-%d-%H-%M')" >> $GITHUB_OUTPUT
      
      - name: Build Docker Image
        run: |
          docker build -t your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }} . 
      
      - name: Push Docker Image To Dockerhub Repository
        run: |
          docker push your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }}

# UPdate the K8s Manifest Files

        # View the old k8s manifest (optional)
      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      # Update the image tag in the Kubernetes manifest file (Required)
      - name: Update Manifests with New Image Tag
        run: |
            sed -i "s|image: wisdom2608/wisdomtech:.*|image: wisdom2608/wisdomtech:${{  steps.date_time.outputs.timestamp }}|g" manifests/deploy.yml

      # View the new k8s manifest after update (optional)
      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml

```
- B) *Workflow file using `find` command to find and replace the image tag in the Kubernetes manifests file*:

```bash

name: Docker Image Build and Push To Docker Hub

on:
  push:
    branches:
      - main
    paths:
      - '**/*' # This will trigger whenever there are changes in any file in the repository
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker
        uses: docker/setup-buildx-action@v2

      - name: Login To Dockerhub With Dockerhub Credentials
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Tag Docker Image With Current Date and Timestamp
        id: date_time
        run: echo "timestamp=$(date +'%Y-%m-%d-%H-%M')" >> $GITHUB_OUTPUT
      
      - name: Build Docker Image
        run: |
          docker build -t your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }} . 
      
      - name: Push Docker Image To Dockerhub Repository
        run: |
          docker push your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }}
# UPdate the K8s Manifest Files

        # View the old k8s manifest before update(optional)
      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      # Update the image tag in the Kubernetes manifest file (Required)
      - name:  Update image tag in manifests
        run: |
          find ./manifests -type f -name "deploy.yml" -exec sed -i "s|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:.*|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:${{ steps.date_time.outputs.timestamp }}|g" {} +

      # View the new k8s manifest after update (optional)
      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml
```

# Step 4: Update or commit the changes Github repository after updating the K8s manifest in the workflow runs.
To allow GitHub Actions to push or disable branch protections, you need to configure the necessary permissions and branch protection settings in your repository:

Granting GitHub Actions Permissions to Push commit changes to your repository,
navigate to your repository's `Settings` → `Actions` → `General`.
Under `Workflow permissions`, select: `"Read and write permissions"` to allow workflows to push changes.
Optionally, enable the checkbox for "Allow GitHub Actions to bypass branch protections" if required.
Save the changes.

- There are two possibilities to configure this in the same workflow file:

a) First possibility

```bash
      
    # Update Github Repository
      - name: Commit and push the updated manifests
        run: |
          git config --global user.email "<>"
          git config --global user.name "GitHub Actions Bot"
          git add manifests/deploy.yml
          git commit -m "Update deploy.yaml with new image tag - ${{ steps.date_time.outputs.timestamp }}"
          git remote set-url origin https://github-actions:${{ secrets.GITHUB_TOKEN }}@github.com/wisdom2608/application.git
          git push origin main

```

b) Second possibility

```bash
# Update Github repository
      - name: Commit and push updated manifests
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"

          # Set remote URL using the GitHub token
          git remote set-url origin https://x-access-token:${GITHUB_TOKEN}@github.com/${{ github.repository }}

          git add .
          git commit -m "Update image tag to ${{ steps.date_time.outputs.timestamp }}" || echo "No changes to commit"
          git push

```

# CONCLUSTION: Here aere two verriefied workflow yml files which you cand use to build and push docker image to dockerhub, update image tags in k8s manifests, and commit the changes to the Github repository. Choose any of the workflow files below

I) 

```bash
name: Docker Image Build and Push To Docker Hub

on:
  push:
    branches:
      - main
    paths:
      - '**/*' # This will trigger whenever there are changes in any file in the repository
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker
        uses: docker/setup-buildx-action@v2

      - name: Login To Dockerhub With Dockerhub Credentials
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Tag Docker Image With Current Date and Timestamp
        id: date_time
        run: echo "timestamp=$(date +'%Y-%m-%d-%H-%M')" >> $GITHUB_OUTPUT
      
      - name: Build Docker Image
        run: |
          docker build -t your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }} . 
      
      - name: Push Docker Image To Dockerhub Repository
        run: |
          docker push your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }}

# UPdate the K8s Manifest Files

        # View the old k8s manifest (optional)
      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      # Update the image tag in the Kubernetes manifest file (Required)
      - name: Update Manifests with New Image Tag
        run: |
            sed -i "s|image: wisdom2608/wisdomtech:.*|image: wisdom2608/wisdomtech:${{  steps.date_time.outputs.timestamp }}|g" manifests/deploy.yml

      # View the new k8s manifest after update (optional)
      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml
      
    # Update Github Repository
      - name: Commit the changes
        run: |
          git config --global user.email "<>"
          git config --global user.name "GitHub Actions Bot"
          git add manifests/deploy.yml
          git commit -m "Update deploy.yaml with new image tag - ${{ steps.date_time.outputs.timestamp }}"
          git remote set-url origin https://github-actions:${{ secrets.GITHUB_TOKEN }}@github.com/wisdom2608/application.git
          git push origin main

```

II)

```bash
name: Docker Image Build and Push To Docker Hub

on:
  push:
    branches:
      - main
    paths:
      - '**/*' # This will trigger whenever there are changes in any file in the repository
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker
        uses: docker/setup-buildx-action@v2

      - name: Login To Dockerhub With Dockerhub Credentials
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Tag Docker Image With Current Date and Timestamp
        id: date_time
        run: echo "timestamp=$(date +'%Y-%m-%d-%H-%M')" >> $GITHUB_OUTPUT
      
      - name: Build Docker Image
        run: |
          docker build -t your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }} . 
      
      - name: Push Docker Image To Dockerhub Repository
        run: |
          docker push your_dockerhub_username/image_name:${{ steps.date_time.outputs.timestamp }}

# UPdate the K8s Manifest Files

        # View the old k8s manifest before update(optional)
      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      # Update the image tag in the Kubernetes manifest file (Required)
      - name:  Update image tag in manifests
        run: |
          find ./manifests -type f -name "deploy.yml" -exec sed -i "s|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:.*|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:${{ steps.date_time.outputs.timestamp }}|g" {} +

      # View the new k8s manifest after update (optional)
      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml

# Update the github Repository
      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml
      - name: Commit and push updated manifests
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"

          # Set remote URL using the GitHub token
          git remote set-url origin https://x-access-token:${GITHUB_TOKEN}@github.com/${{ github.repository }}

          git add .
          git commit -m "Update image tag to ${{ steps.date_time.outputs.timestamp }}" || echo "No changes to commit"
          git push

```
# The Downside Of Having The Source Code and The Manifest Files In The Same Repository.
The disadvantage of this approve is that we'll alway have to do `git pull` before updating our source code locally. This is because the update made on k8s manifest file is made on the remote repository. The change in image tag does not affect k8s manifest file in our local environment. So, have these changes, we must run `git pull`. 

This means that anytime that we've to update our application source code, we've to do `git pull`. This makes our job tidious. To solve this problem, our application source code and k8s manifests files should be kept in different Github repositories. My next project will be to *build and push docker image to dockerhub* in `application` repository and then *update image tags in the k8s manifest file and commit the changes* to the `k8s manifest` repository.

# 🛠 Here is a project to build and push Docker image to Dockerhub using github actions and then, update Kubernetes manifest files which in a separate repository within the same GitHub account.

# Workflow repository link: https://github.com/wisdom2608/app_source_code
# kubernetes manifests repository link: https://github.com/wisdom2608/k8s_manifest

