resource "digitalocean_droplet" "pfsense" {
  image = "debian-11-x64"
  name = "pfsense"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.system76.id
  ]
  
  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = ["echo something"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.pvt_key)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e '' pfsense.yml"
  }
}
  
