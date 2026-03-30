# Azure Zero Trust Platform

Terraform-built Azure environment implementing Zero Trust principles across identity and network layers, with private access to PaaS resources and enforced least-privilege access.

## Objective
- Enforces least-privilege access using RBAC and Conditional Access
- Segments network traffic to minimize lateral movement
- Removes public exposure of resources using private endpoints
- Uses Infrastructure as Code for consistent, repeatable deployments

## Architecture Overview

### Identity Layer
- Entra ID Groups:
    - Platform Admins - Contributor access
    - App Users - Reader access
    - Contractors - Reader access (restricted)
- RBAC scoped at the resource group level
- Conditional Access enforcing MFA
- External user onboarding via Az AD B2B
# Full design: docs/identity-design.md

### Network Layer
- Virtual Network with segmented subnets:
    - App subnet
    - Data subnet
    - Private endpoint subnet
- NSGs enforcing least-privilege traffic rules
- Private Endpoint for Azure Storage
- Private DNS zone for internal name resolution
- Public network access disabled on storage account

## Key Design Decisions
- Private Endpoints over public access
Ensures storage is only accessible within the VNet, eliminating internet exposure
- Subnet segmentation
Reduces lateral movement and enforces separation between application and data layers
- NSG enforcement
Explicitly restricts traffic instead of relying on Azure's permissive defaults
- Conditional Access with MFA
Protects privileged and external access paths


## Deployment

```bash
terraform init
terraform plan
terraform apply
```
Remote state is stored in Azure storage

## Project Structure

```
terraform/
  ├── modules/
  │     └── network/
  ├── backend.tf
  ├── providers.tf
  ├── main.tf

docs/
  ├── identity-design.md
  ├── networking-decisions.md

diagrams/
```

## Roadmap
- Deploy application workload with private backend connectivity
- Enable centralized logging (Log Analytics, diagnostics)
- Modularize Terraform for multi-environment support
- Implement Azure DevOps pipeline with OIDC authentication
- Build end-to-end access scenario (external contractor)