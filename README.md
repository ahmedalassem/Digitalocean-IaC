# DigitalOcean Infrastructure as Code (IaC)

Provisioning different types of infrastructure on DigitalOcean using Terraform, making the process automated, reusable, and customizable.

## Features

1. Automates provisioning of cloud resources on DigitalOcean using Terraform.
2. Provides a reusable and maintainable setup for various infrastructure components.
3. Easily customizable to fit different deployment needs.

## Prerequisites

1. **Terraform Version 1.0 or Higher**: Make sure Terraform is installed and up to date. [Download here](https://www.terraform.io/downloads.html).
2. **DigitalOcean Account**: Create an account and generate an API token from your DigitalOcean dashboard.
3. **SSH Key**: Add your machine's public SSH key to DigitalOcean from [here](https://cloud.digitalocean.com/account/security).
4. **Domain**: A ready-to-use domain to point to the infrastructure.

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/ahmedalassem/Digitalocean-IaC.git
   cd Digitalocean-IaC
   ```

2. **Configure DigitalOcean API Token**: Set up your API token as an environment variable.
   ```bash
   export DO_PAT=your_digitalocean_api_token
   ```

3. **Add SSH Key to DigitalOcean**: Make sure your machine's public SSH key is added to DigitalOcean. You can add it from the [Security Page](https://cloud.digitalocean.com/account/security).

4. **Modify provider.tf**: Update `provider.tf` file with your API token or preferred settings. You may also set up other variables as per your requirements.

5. **Initialize Terraform**
   ```bash
   terraform init
   ```

6. **Plan the Infrastructure**: Run Terraform plan to see what changes will be made.
   ```bash
   terraform plan \
     -var "do_token=${DO_PAT}" \
     -var "pvt_key=$HOME/.ssh/id_rsa"
   ```

7. **Apply the Infrastructure**: Deploy the infrastructure to DigitalOcean.
   ```bash
   terraform apply \
     -var "do_token=${DO_PAT}" \
     -var "pvt_key=$HOME/.ssh/id_rsa"
   ```

## Resources Created

1. **Droplets (Virtual Machines)**: Two droplets are created to run the application.
2. **Load Balancer**: A load balancer is set up to manage traffic between the droplets.
3. **Domain Record**: A domain record is created to point to the load balancer.

## Files Overview

1. **domain_root.tf**: Sets up a domain pointing to the load balancer.
   ```hcl
   resource "digitalocean_domain" "default" {
     name = "terraform.domain.com"
     ip_address = digitalocean_loadbalancer.IaC-lb.ip
   }
   ```

2. **loadbalancer.tf**: Configures the load balancer.
   ```hcl
   resource "digitalocean_loadbalancer" "IaC-lb" {
     name   = "IaC-lb"
     region = "nyc3"

     forwarding_rule {
       entry_port      = 80
       entry_protocol  = "http"
       target_port     = 80
       target_protocol = "http"
     }

     healthcheck {
       port     = 22
       protocol = "tcp"
     }

     droplet_ids = [digitalocean_droplet.IaC.id, digitalocean_droplet.IaC2.id]
   }
   ```

3. **tf_test.tf & tf_test2.tf**: Provisions two droplets, each running Ubuntu 20.04 and installing Nginx.
   ```hcl
   resource "digitalocean_droplet" "IaC" {
     image      = "ubuntu-20-04-x64"
     name       = "IaC"
     region     = "nyc3"
     size       = "s-1vcpu-1gb"
     ssh_keys   = [data.digitalocean_ssh_key.terraform.id]

     connection {
       host         = self.ipv4_address
       user         = "root"
       type         = "ssh"
       private_key  = file(var.pvt_key)
       timeout      = "2m"
     }

     provisioner "remote-exec" {
       inline = [
         "export PATH=$PATH:/usr/bin",
         "sudo apt update",
         "sudo apt install -y nginx"
       ]
     }
   }
   ```

4. **domain-A.tf**: Sets up an A record for the domain.
   ```hcl
   resource "digitalocean_record" "A-IaC" {
     domain = digitalocean_domain.default.name
     type   = "A"
     name   = "terraform"
     value  = "Server-IP-Address"
   }
   ```

## References

- [How to Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean): A guide to using Terraform for managing resources on DigitalOcean.

## Future Improvements

- **Automate Backups**: Implement a backup solution for the droplets and databases.
- **Monitoring and Alerts**: Add monitoring using tools like Prometheus and Grafana to monitor the health of the infrastructure.
- **Scaling**: Implement horizontal scaling for the droplets to handle increased traffic.

