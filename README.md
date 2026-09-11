# devops-excercise

## Objective
Evaluate proficiency in DevOps practices, including continuous integration, continuous deployment, infrastructure automation, monitoring, and troubleshooting.

**Duration:** 4 hours

Each task below is designed to assess specific skills and competencies. Detailed explanations and any code written should be documented for review.

## Task 1: Continuous Integration and Deployment (CI/CD)

1. **Setup CI Pipeline**
   - Create a GitHub repository for a sample application (can be a simple web app).
   - Configure a CI pipeline using GitHub Actions to automatically build the application whenever a commit is pushed to the main branch.
   - Ensure the pipeline includes steps for code linting, unit testing, and building the application.
2. **Setup CD Pipeline**
   - Extend the CI pipeline to include deployment steps.
   - Deploy the application to a cloud service provider (e.g., AWS, Azure).
   - Use infrastructure-as-code (IaC) tools like Terraform to manage the deployment.

## Task 2: Infrastructure Automation

1. **Provisioning**
   - Write a Terraform script to provision the necessary infrastructure (e.g., virtual machines, load balancers, databases) for the sample application.
   - Ensure the script is modular and reusable.
2. **Configuration Management**
   - Use Ansible to configure the provisioned infrastructure.
   - Install necessary packages, configure environment variables, and deploy the application.

## Task 3: Monitoring and Logging

1. **Monitoring Setup**
   - Implement monitoring for the application using a tool like Prometheus.
   - Set up alerts for key performance indicators (KPIs) such as CPU usage, memory usage, and error rates.
2. **Logging Setup**
   - Configure centralized logging using a tool like ELK Stack (Elasticsearch, Logstash, Kibana).
   - Ensure logs from all components of the application are collected and indexed for easy search and analysis.

## Task 4: Troubleshooting

1. **Scenario-Based Troubleshooting**
   - Present a scenario where the application is experiencing performance issues (e.g., high response times, frequent errors).
   - Identify the root cause and propose solutions.
   - Document the approach to debugging and resolving the issue.

## Deliverables

1. **GitHub Repository**
   - Link to the GitHub repository containing the application code, CI/CD pipeline configuration, and Terraform scripts.
2. **Documentation**
   - Detailed documentation explaining the CI/CD pipeline setup, infrastructure provisioning, configuration management, monitoring setup, and troubleshooting steps.
   - Any assumptions made and challenges encountered during the exercise.


