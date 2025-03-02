# Spring Boot CI/CD & Infrastructure as Code (IAC) Project

## Infrastructure with Terraform

This project provisions the necessary cloud infrastructure using **Terraform** with modular design.

![Terraform Deployment](./Documentation_Diagrams/Terraform_Deployment.gif)

### Terraform Modules

1. **Network Module**
   - Creates two public subnets, a security group, and a route table.
   - Sets up the network infrastructure for the project.

2. **EKS Cluster Module**
   - Deploys an Amazon EKS cluster within the **Network Module** subnets.
   - Creates a node group using a launch template that references the **Amazon EKS AMI**.
   - Enables **IMDSv2** (Instance Metadata Service v2) to allow worker nodes to access their assigned IAM roles securely.
   - Ensures worker nodes can assume the necessary IAM roles.
   - Attaches worker nodes to the **Network Module** security group.

3. **ACM Module**
   - Provisions a **public certificate** for the custom domain `mosama.site`.
   - Issues a **wildcard certificate** (`*.mosama.site`) for subdomain support.

### Terraform Backend
- Uses **Amazon S3** for state file storage.
- Implements **DynamoDB** for state locking to prevent concurrent modifications.

### Helm Provider
- Utilizes the **Terraform Helm provider** to install required **Helm charts**.

### GitHub Actions - Terraform Workflow
- A GitHub Actions workflow (`Terraform.yml`) automates the **Terraform** lifecycle.
- The workflow supports **manual triggers** with two inputs:
  - `apply` → Deploys the infrastructure.
  - `destroy` → Destroys the infrastructure.

## Helm Charts
1. **AWS Load Balancer Controller**
   - Serves as the **Ingress Controller**.
   - Preferred over **NGINX Ingress Controller** due to its capability to automatically discover AWS public certificates for custom domains.
   - Automatically detected and applied the certificate for `mosama.site`, ensuring efficient ingress rule management.

2. **External DNS**
   - Bridges **Kubernetes** with **Route 53** hosted zone.
   - Automatically creates **Route 53** records when an ingress rule is added.
   - Maps domain names to the **Load Balancer** DNS dynamically.

3. **EBS CSI Driver**
   - Enables provisioning of Kubernetes volumes using **gp2** storage class.
   - Automates **AWS EBS** volume creation for persistent storage needs.

4. **SonarQube Helm Chart**
   - Deploys **SonarQube** for code quality analysis.
   - Configured ingress with `sonarqube.mosama.site` and **ALB Ingress Controller**.
   - Modified **PostgreSQL storage class** to **gp2** for persistent volume provisioning.

5. **ARC Runner Scale Set Chart**
   - Deploys and manages GitHub Actions **self-hosted runners** in Kubernetes.
   - Defines runner pods that execute GitHub Actions workflows.
   - Scales dynamically based on job demand.

6. **ARC Runner Scale Set Controller Chart**
   - Manages the scaling and lifecycle of the runner scale set.
   - Ensures efficient resource utilization by dynamically provisioning and deprovisioning runner pods.
   - Adjusts the number of available runners based on workload demand.

## ARC Self-Hosted GitHub Runner

To improve control over self-hosted runners, a **custom ARC runner image** was created.

### Custom ARC Runner Image
- Built using a **Dockerfile** named `Custom_ARC_Image_DockerFile`.
- Based on the default runner image with additional pre-installed packages:
  - **Java 18**
  - **AWS CLI**
  - **kubectl**
  - **Helm**
  - Other required dependencies.

### Building & Pushing the Image
- A GitHub Actions workflow (`new_acr_runner_image_push.yml`) automates the build and push process.
- The custom runner image is pushed to **Docker Hub**.

### Deploying the Custom Runner
- The custom image is referenced in the **ARC Runner Scale Set Chart** by updating `my_values.yaml` with `image:tag`.
- This ensures that new workflow runs use the customized runner image.

### Testing the Custom Runner
- A test workflow (`ARC_Test.yml`) was executed using the new runner.
- Verified that all pre-installed packages were available and functional within the runner environment.

## Kubernetes Manifests

Initially, the plan was to deploy standard Kubernetes manifests in separate **dev** and **prod** namespaces. However, a challenge arose with **Ingress**, as it operates within a namespace scope. To address this, a dedicated **Helm chart** was created: `spring-boot-app-chart`.

### Spring Boot App Helm Chart
The custom **Helm chart** includes:

- **Deployment**: Defines the application pod and uses a templated image value for flexibility.
- **Service (NodePort)**: Required for AWS ALB, exposing the application externally.
- **Ingress**:
  - Uses an ALB ingress with a **shared group** to consolidate multiple ingress rules under the same load balancer.
  - Configured to enforce **HTTPS redirection** for security.
  - Templated `host` value for dynamic configuration via the `values.yaml` file.
  - Supports multiple path-based routing rules (`/` and `/live`).

By templating key values, the chart ensures **reusability** across different environments while maintaining best practices for **security**, **scalability**, and **ingress management**.


## Spring Boot Application CI/CD Pipeline

![Pipeline Diagram](./Documentation_Diagrams/cicd.gif)

The CI/CD pipeline (`CICD.yml`) executes on a **self-hosted ARC runner** within a Kubernetes pod. The workflow runs on every push to the `dev` branch and follows these steps:

### Repository Setup and Versioning
1. **Checkout Repository**
   - Uses `actions/checkout@v3` to pull the latest code from the repository.

2. **Set up Versioning**
   - Dynamically sets the application version using environment variables (`MAJOR.MINOR.PATCH`). The patch number is incremented automatically in each build by using the `GITHUB_RUN_NUMBER` environment variable.

### Code Quality and Testing
3. **Run Checkstyle Linting**
   - Runs `./gradlew checkstyleMain checkstyleTest` to check for code style violations.

4. **Upload Checkstyle Reports**
   - Stores the reports in an artifact for later review.

5. **Run Unit Tests**
   - Executes `./gradlew test` to ensure the correctness of the code.

6. **Run SonarQube Scan**
   - Performs code quality analysis and checks for vulnerabilities.
   - Moves the report to the root directory for better access.
   - Performs a SonarQube quality gate check.

### Build and Containerization
7. **Build Application**
   - Uses `./gradlew build` to compile and package the Spring Boot application.

8. **Build Docker Image**
   - Builds a Docker image with a versioned tag.

9. **Log in to DockerHub**
   - Authenticates with Docker Hub using stored credentials.

10. **Push Docker Image**
    - Pushes the built image to Docker Hub.

### Deployment to Kubernetes
11. **Configure AWS credentials**
    - Sets up AWS authentication to access the EKS cluster.

12. **Configure kubectl**
    - Updates the kubeconfig file to communicate with the Kubernetes cluster.

13. **Update Image Tag in Helm Chart**
    - Updates the Helm values file to use the new Docker image tag.

14. **Deploy to Development Environment**
    - Uses Helm to deploy the application in the `dev` namespace.

15. **Deploy to Production Environment**
    - Uses Helm to deploy the application in the `prod` namespace.

This pipeline ensures a **fully automated**, **efficient**, and **secure deployment process** for the Spring Boot application.
