# Azul DevOps Task Documentation

## Architecture and Components

The system architecture leverages AWS services, integrating them to form a cohesive, scalable solution for web hosting and data processing. Below is an in-depth look at each component:

### Private S3 Bucket Configuration

- **Purpose:** Dual functionality in hosting the `index.html` for web access and storing weather data in a `/data` folder.
- **Features:** 
  - **Data Storage:** The `/data` directory is dedicated to weather data, keeping it separate from static web resources.
  - **Web Hosting:** Hosts `index.html` at the root for direct web access.
  - **Versioning:** Enabled for the entire bucket, facilitating easy rollback of `index.html` to prior versions.

### CloudFront Distribution

- **Purpose:** Facilitates global content delivery of `index.html`, optimizing for speed and reliability.
- **Integration:** Configured to serve static content directly from the S3 bucket.

### ACM and Route 53 Configuration

- **ACM:** Manages SSL/TLS certificates for HTTPS access to the CloudFront distribution.
- **Route 53:** Handles domain name services, linking `asklepijes.com` to CloudFront for streamlined web access.

### ECS (Fargate)

- **Purpose:** Manages the execution of the containerized weather API, automating the retrieval and storage of weather data and `index.html`.

### ECR

- **Purpose:** Acts as a repository for the Docker images of the weather API, facilitating seamless deployment.

### EventBridge

- **Functionality:** Triggers the ECS task on an hourly schedule to update weather data and the webpage.
- **Manual Configuration:** Post-deployment, the EventBridge target is manually updated to select the latest ECS task definition, ensuring that the most recent application version is executed.

### CI/CD Pipeline

- **Process:**
  - **Image Deployment:** Automatically builds and pushes the updated Docker image to ECR.
  - **Task Definition Rendering:** Dynamically generates new ECS task definitions to incorporate the latest Docker image.
  - **Resource Optimization:** Implements a script to clean up old task definitions, retaining only the latest ten for efficiency.
  - **Security:** Leverages OIDC with GitHub Actions for secure, credential-less CI/CD operations, using temporary, scoped access tokens.
