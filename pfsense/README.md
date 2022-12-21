### PFSense terraform deployment for DigitalOcean
Niles Ingalls 2022\
Apache License 2.0\
\
# If you need a pfSense deployment within DigitalOcean, this is for you.
\
DigitalOcean removed FreeBSD support earlier this year (2022), which removed\
the ability to deploy pfSense as a custom image.\
\
Why do I want pfSense you might ask?  My usage is to network a handful of Snom VoIP\
phones and openwrt devices over a VPN.  Until I can find a quality VoIP phone that\
supports wireguard, pfSense with OpenVPN is my preferred approach.\
pfSense requires an interractive installation, so I've broken this up into 3 steps.\
\
## Step 1 - Deploy a DigitalOcean Debian droplet.  
My approach is to use terraform to spin up a Debian 11 droplet, and execute an ansible\
playbook that will lead you right up to step 2, manually configuring pfSense.  More on that in a moment.\
This will require you to install both terraform and ansible from your workstation, or you can install\
the droplet manually and even run from within the droplet.\
\
(set your DO_PAT environment variable, and add your workstation public key to your digitalocean account)\
\
### Terraform approach:
terraform plan -var "do_token=${DO_PAT}" -var "pvt_key=$HOME/.ssh/id_rsa"\
\
(make sure this looks good)\
\
terraform apply -var "do_token=${DO_PAT}" -var "pvt_key=$HOME/.ssh/id_rsa"\
\
### Ansible only approach:
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '{droplet_ip_address},' --private-key ~/.ssh/id_rsa pfsense.yml\
\
When is is complete, you'll have a server that is running pfSense in nested virtulization with access ports (80/443/5900) locked\
to your workstation IP address to manage & access pfSense.\
\
## Step 2 - manual install/setup of pfSense
Log into your droplet (ssh root@{droplet_ip_address})\ 
virsh console pfSense\
(enter the following responses)\
Console Type [vt100]:			<enter>\
Copyright and Trademark Notices: 	<Accept>\
Install PfSense				< OK >\
Continue with default keymap		<Select>\
Auto (ZFS)				< OK >\
Install (Proceed with Installation)	<Select>\
stripe - Stripe - No Redundancy		< OK >\
vtbd0 vtbd1				( ONLY SELECT vtbd1 )\
Last Chance!				< YES >\
exit to shell\
\
Now, exit the console (CONTROL+]) but don't exist virsh.  Then, do the following:\
detach-disk --domain pfSense /var/lib/libvirt/images/pfSense-CE-memstick-serial-2.6.0-RELEASE-amd64.img --persistent --config --live\
\
\
destroy pfSense\
start pfSense\
console pfSense\
\
(continue configuration)\
Should VLANs be set up now [y|n]?	n\
Enter the WAN interface name or 'a' for auto-detection\
(vtnet0 vtnet1 or a):			vtnet0\
Enter the LAN interface name or 'a' for auto-detection\
(vtnet1 a or nothing if finished):	vtnet1\
do you want to proceed [y|n]?		y\
The interfaces will be assigned as follows:\
WAN  -> vtnet0\
LAN  -> vtnet1\
Do you want to proceed [y|n]? 		y\
\
you're back at the pfSense menu selection.  Select 8) Shell and execute the following:\
pfSsh.php playback disablereferercheck\
\
log out of pfSense (CONTROL+])\
\
## Step 3 - configure Apache and Envoy 
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '{droplet_ip_address},' --private-key ~/.ssh/id_rsa -e '' pfsense_post_vm.yml\
\
Once this is complete, you can access pfSense via VNC, or HTTPS.\
Setup an OpenVPN Server and start configuring your devices.\
Note, if you use the Client Export tool to provide you VPN config files, you'll need to edit the hostname to match your droplet IP or FQDN.\

