# AWS ECS Architecture 

A highly available and secure AWS architecture designed for hosting containerized applications using Amazon ECS and Amazon RDS PostgreSQL.The solution leverages an Application Load Balancer, private application and database subnets, Security Groups, and  deployment to ensure scalability, reliability, and controlled network access.

## Components

- VPC (10.0.0.0/16)
- Application Load Balancer (ALB)
- ECS Cluster (Private App Subnets)
- RDS PostgreSQL Multi-AZ (Private DB Subnets)
- Security Groups
- Multi-AZ Deployment

## Traffic Flow

Internet  
→ ALB (Public Subnets)  
→ ECS Tasks (Private App Subnets)  
→ RDS PostgreSQL (Private DB Subnets)

## Security Groups

### ALB SG
- Inbound: 80, 443 from Internet
- Outbound: ECS SG

### ECS SG
- Inbound: Application Port from ALB SG
- Outbound: 5432 to DB SG

### DB SG
- Inbound: 5432 from ECS SG

## AWS Services Used

- Amazon VPC
- Application Load Balancer (ALB)
- Amazon ECS
- Amazon RDS PostgreSQL
- Security Groups
- Availability Zones

## Learnings

- Designing secure network architectures using public and private subnets
- Configuring Security Groups for controlled communication
- Deploying containerized applications using Amazon ECS
- Implementing load balancing with ALB
- Setting up highly available databases using RDS Multi-AZ
- Understanding traffic flow between application and database layers
- Following AWS best practices for scalability and security
