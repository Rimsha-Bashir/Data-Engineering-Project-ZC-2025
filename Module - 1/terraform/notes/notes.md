### DE Zoomcamp 1.3.1 - Terraform Primer

Terraform is an IaaS/IaaC tool that helps you define/provision cloud and on-prem resources in a human-readable config file that you can version, reuse and share. 

#### Why Terraform?
- To keep track of avaiable infrastructural resources-- size of the disk, types of storage etc. 
- Easier collab, because it's defined in config files. 
- Reproducible, can be used in different application development projects with similar skeleton configs. You can change parameters defined and reuse as needed. 
- Ensures resources are removed once their use is done/are deallocated. 

#### What it doesn't do?
- It's not made to deloy, update software.. 
- Or modify resources (like OS type)
- It does not manage code on infrastructure. 
- Not used to manage resources not mentioned in the terraform config files.

#### What is a terraform provider?
Provider in Terraform is a plugin that enables interaction with an API. This includes Cloud providers and Software-as-a-service providers. The providers are specified in the Terraform configuration code, they allow Terraform to interact will different services, like AWS, GCP etc. (Check out Hashicorp Terraform registry)

#### Terraform Commands

* \terraform init\: initialize a working directory containing Terraform configuration files

* \terraform plan\: show changes Terraform will make to your infrastructure

* \terraform apply\: apply changes Terraform will make to your infrastructure

* \terraform destroy\: destroy all resources Terraform created

### DE Zoomcamp 1.3.2 - Terraform Basics
