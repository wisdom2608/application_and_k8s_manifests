# Build and push docker image to dockerfile and then update kubernetes manifest file with the latest tag
# Step 1: Create a github repository  for your application  source code
  - name of the repository: `application`
  - Inside `application` repo:
        -  create a `.github/workflows/main.yml` directry.
        -  create another directry `manifests`
        -  inside of `manifests`, create `service.yml` and `deploy.yml` files.

# Step 2: Build and push the image
  - Here is the workflow jobs

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

# Step 3: After to image is built and pushed to dockerhub successfully, you can update k8s manifest files with the latest image tag

- In the same workflow file, you add the steps for the image tag update. # There  two ways to update the image tag in the Kubernetes manifests file:

- a) *Using `sed` command to find and replace the image tag in the Kubernetes manifest file direclty*:

```bash
# UPdate the K8s Manifest Files

      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

     - name: Update Manifests with New Image Tag
        run: |
          sed -i "s|image: your_dockerhub_username/image_name:.*|image: your_dockerhub_username/image_name:${{  steps.date_time.outputs.timestamp }}|g" manifests/deploy.yml

      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml

```
- b) *Using `find` command to find and replace the image tag in the Kubernetes manifests file*:

```bash
# UPdate the K8s Manifest Files

      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      - name: Update Kubernetes manifests
        run: |
          find ./manifests -type f -name "deploy.yml" -exec sed -i "s|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:.*|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:${{ steps.date_time.outputs.timestamp }}|g" {} +

      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml
```
# NB: Choose any of the workflow files below for your project but not both.

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

      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

     - name: Update Manifests with New Image Tag
        run: |
          sed -i "s|image: your_dockerhub_username/image_name:.*|image: your_dockerhub_username/image_name:${{  steps.date_time.outputs.timestamp }}|g" manifests/deploy.yml

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

      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      - name: Update Kubernetes manifests
        run: |
          find ./manifests -type f -name "deploy.yml" -exec sed -i "s|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:.*|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:${{ steps.date_time.outputs.timestamp }}|g" {} +

      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml
```

# Step 4: Updating the repository after updating the K8S manifest in the workflow runs.
To allow GitHub Actions to push or disable branch protections, you need to configure the necessary permissions and branch protection settings in your repository:

1. Granting GitHub Actions Permissions to Push
Navigate to your repository's Settings → Actions → General.
Under Workflow permissions, select:
"Read and write permissions" to allow workflows to push changes.
Optionally, enable the checkbox for "Allow GitHub Actions to bypass branch protections" if required.
Save the changes.

- There are two possibilities to configure this in the same workflow file:

a) First possibility

```bash
      
    # Update Github
      - name: Commit the changes
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

# NB: Two possible workflow yaml files to build and push docker image to dockerhub, update image tags in k8s manifests, and update(commit the change) to the repository. Choose any of the workflow files below

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

      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

     - name: Update Manifests with New Image Tag
        run: |
          sed -i "s|image: your_dockerhub_username/image_name:.*|image: your_dockerhub_username/image_name:${{  steps.date_time.outputs.timestamp }}|g" manifests/deploy.yml

      - name: Show Updated Kubernetes Manifest
        run: cat manifests/deploy.yml
      
    # Update Github
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

      - name: Show Original Kubernetes Manifest
        run:  |
          cat manifests/deploy.yml

      - name: Update Kubernetes manifests
        run: |
          find ./manifests -type f -name "deploy.yml" -exec sed -i "s|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:.*|${{ secrets.DOCKERHUB_USERNAME }}/wisdomtech:${{ steps.date_time.outputs.timestamp }}|g" {} +

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


