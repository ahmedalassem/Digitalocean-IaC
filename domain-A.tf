resource "digitalocean_record" "A-IaC" {
  domain = digitalocean_domain.default.name
  type = "A"
  name = "terraform"
  value = "Server-IP-Address"
}
