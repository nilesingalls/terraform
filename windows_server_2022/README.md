### Windows Server 2022 deployment for DigitalOcean
Niles Ingalls 2022\
Apache License 2.0

# If you need to run windows in DigitalOcean for some reason (and I can't think of any reason I would need to), this is for you.
This was an excercise I whipped up in order to see how well Windows performs in nested virtualization on a minimally resourced droplet.\
It doesn't perform very well as you could imagine, but you're welcome to crank up the resources defined win2022.tf and have a go!

Tinker with the envoy configuration if you want to pass anything beyond 3389 to the Windows machine.  This config will proxy 80/443 to Windows\
which depends on you logging into the machine and installing IIS.
## Step 1 - Deploy a DigitalOcean Debian droplet and add a volume.
Terriform will kick off an ansible playbook that mounts the additional volume, setups some firewall rules, downloads Windows2022 & Virtio drivers.
## Step 2 - Once Windows is up and running, vnc to your droplet IP address to setup your Administrator password.  Login, install virtio & iis (or whatever) then move to step 3.
## Step 3 - kick off the second ansible playbook which will configure apache and envoy.
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '{droplet_ip_address},' --private-key ~/.ssh/id_rsa -e '' win2022_post_vm.yml\
Once this has completed, you'll be able to RDP into your windows machine.  If you install IIS, you'll be able to pull up your droplet IP address in a browser and the IIS splash page.

![win2022 post login](/assets/digital_ocean_win2022_a.png)
![win2022 Virtio driver installation](/assets/digital_ocean_win2022_b.png)
![win2022 IIS installation](/assets/digital_ocean_win2022_c.png)
![win2022 splash page](/assets/digital_ocean_win2022_d.png)
