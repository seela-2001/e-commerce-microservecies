# DevOps & Deployment Automation

This document outlines the DevOps practices and the automated CI/CD pipeline for deploying the Flipkart MERN clone application.

## Technology Stack

The automation and deployment process relies on the following technologies:

-   **Cloud Provider:** Amazon Web Services (AWS)
-   **Infrastructure as Code (IaC):** Terraform
-   **Configuration Management:** Ansible
-   **Containerization:** Docker & Docker Compose
-   **CI/CD:** GitHub Actions

## Deployment Workflow

The entire deployment process is automated through a GitHub Actions workflow defined in `.github/workflows/deploy.yaml`. The workflow is triggered on a `push` to the `main` or `last-deploy` branches and can also be run manually.

The pipeline executes the following stages:

### 1. Infrastructure Provisioning with Terraform

-   **Authentication:** The workflow authenticates with AWS using credentials stored securely as GitHub Secrets.
-   **Provisioning:** Terraform reads the configuration files in the `/terraform` directory to provision the required AWS infrastructure. This includes:
    -   An EC2 instance to host the application.
    -   A security group to define firewall rules (e.g., allowing traffic on ports 22, 80, and 443).
    -   An SSH key pair for secure access to the EC2 instance.
-   **Outputs:** After applying the infrastructure plan, Terraform outputs the public IP address of the EC2 instance and the path to the private SSH key.

### 2. Server Configuration with Ansible

-   **Dynamic Inventory:** The workflow generates an Ansible inventory file (`hosts.ini`) using the IP address obtained from Terraform.
-   **Provisioning:** An Ansible playbook (`/ansible/playbook.yaml`) runs to configure the server. This playbook performs tasks such as:
    -   Updating the package manager.
    -   Installing necessary software like Docker, Docker Compose, and Node.js.
    -   Adding the `ubuntu` user to the `docker` group to allow running Docker commands without `sudo`.

### 3. Application Deployment

-   **Code Transfer:** The latest version of the application code is securely copied from the GitHub runner to the EC2 instance using `rsync` over SSH. The `terraform`, `.git`, and `ansible` directories are excluded.
-   **Environment Configuration:** The workflow creates `.env` files for both the backend and frontend on the EC2 instance. The contents of these files are sourced from GitHub Secrets to protect sensitive information like database connection strings and API keys.

### 4. Running the Application with Docker

-   **Container Orchestration:** Docker Compose is used to build and run the application services as defined in the `docker-compose.yaml` file.
-   **Execution:** The workflow connects to the EC2 instance via SSH and runs `docker compose up -d --build`. This command builds fresh images if the source code has changed and starts all services (frontend, backend, database) in detached mode.

## How to Run the Deployment

### Prerequisites

1.  **AWS Account:** You need an AWS account with permissions to create the resources defined in the Terraform files.
2.  **GitHub Repository:** The code should be in a GitHub repository with GitHub Actions enabled.
3.  **GitHub Secrets and Variables:** The following must be configured in your repository's settings (`Settings > Secrets and variables > Actions`):
    -   `AWS_ACCESS_KEY_ID`: Your AWS access key.
    -   `AWS_SECRET_ACCESS_KEY`: Your AWS secret key.
    -   `ENV_BACKEND_CONTENT`: The content of the `.env` file for the backend.
    -   `ENV_FRONTEND_CONTENT`: The content of the `.env` file for the frontend.
    -   `AWS_REGION` (as a Variable): The AWS region to deploy to (e.g., `us-east-1`).

### Triggering the Workflow

You can trigger the deployment in one of two ways:

1.  **Push to a Branch:** Push your changes to the `main` or `last-deploy` branch.
    ```bash
    git push origin main
    ```
2.  **Manual Dispatch:**
    -   Navigate to the "Actions" tab in your GitHub repository.
    -   Select the "Deploy Infra & Configure Server" workflow.
    -   Click the "Run workflow" button.

After the workflow completes successfully, the application will be running and accessible via the public IP address of the EC2 instance.
