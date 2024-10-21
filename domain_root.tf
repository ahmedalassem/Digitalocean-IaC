resource "digitalocean_domain" "default" {
   name = "terraform.domain.com"
   ip_address = digitalocean_loadbalancer.IaC-lb.ip
}
