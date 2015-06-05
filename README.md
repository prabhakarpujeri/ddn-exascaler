# ddn-exascaler
Ansible playbooks to deploy a DDN [EXAScaler](http://www.ddn.com/products/lustre-file-system-exascaler/). 

The DVD from DDN is based off of CentOS-6.5 using their sfa12kx-2.1.1 release. The playbooks work on the assumption that you're using cobbler to manage and pxe boot your systems and running CentOS.

1. Define your MDS and OSS servers as `host_vars` files.
2. Confirm the `group_vars` variables are accurate.
3. You can run the following command `$ ansible-playbook -i hosts setup.yml` or perform the install in a step-wise fashion below.
4. Run the cobbler role `$ ansible-playbook -i hosts -t cobbler setup.yml` to add the iso to cobbler, populate the system list with your MDS and OSS servers from the `host_vars` file, and implement the DDN specific kickstart file.
5. Run the boot role `$ ansible-playbook -i hosts -t boot setup.yml` to ensure the MDS and OSS servers are ready to pxe on reboot and that cobbler is prepared to serve the kickstart. A final prompt is issued before the power cycle; *this step requires extensive wait as it images the servers and reboots them*.
6. Run the exascaler role `$ ansible-playbook -i hosts -t exascaler setup.yml` to generate the `exascaler.conf` file to all servers and run the DDN scripts. 

**The exascaler role past the `exascaler.conf` step should be a replacement for running `/opt/ddn/config/install` but it isn't there yet.**
