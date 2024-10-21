resource "digitalocean_loadbalancer" "IaC-lb" {
  name = "IaC-lb"
  region = "nyc3"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.IaC.id, digitalocean_droplet.IaC2.id ]
}
