resource "digitalocean_volume" "win2022" {
  region                  = "nyc3"
  name                    = "win2022"
  size                    = 100
}

resource "digitalocean_volume_attachment" "foobar" {
  droplet_id = digitalocean_droplet.win2022.id
  volume_id  = digitalocean_volume.win2022.id
}

resource "digitalocean_droplet" "win2022" {
  image = "debian-11-x64"
  name = "win2022"
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
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e '' win2022.yml"
  }

}
  
