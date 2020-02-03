# Vault Trusted Broker Demo

The code in this demo will build a local Consul cluster with a single Vault server, a Jenkins master and a separates Jenkins worker. Several utility scripts are provided to configure Vault to create the AppRoles needed and to configure the demo jobs on Jenkins.

The idea behind the demo is that Jenkins will broker trust on Vault's behalf (thus become a "Trusted Broker") and Vault can issue wrapped Secret-Ids via Jenkins for the "build job" running on the worker node to unwrap on it's behalf.

Once all the steps below have been followed, just run the `create-wrapped-secret-id` job.

## Important Notes

1. **Note:** As of 2nd January 2019, there is an incompatibility between Vagrant 2.2.6 and Virtualbox 6.1.X. Until this incompatibility is fixed, it is recommended to run Vagrant with Virtualbox 6.0.14 instead.

2. **Note:** This demo aims to demonstrate how Jenkins could be used to broker trust for Vault by providing role IDs and wrapped secret IDs for the Jenkins worker to consume. It does **not** intend to demonstrate how to build a Vault and Consul deployment according to any recommended architecture, any recommended standard for configuring Jenkins, nor does it intend to demonstrate any form of best practice with any component. Amongst many other things, you should always enable ACLs, configure TLS and never store your Vault unseal keys or tokens on your Vault server!

## Requirements
* The VMs created by the demo will consume a total of 3GB memory.
* The demo was tested using Vagrant 2.2.6 and Virtualbox 6.0.14
* The demo runs a single provisioning script to generate an SSH key (create-jenkins-keys.sh). This was tested on mac OSX 10.15.3, but your mileage may vary on other operating systems (especially Windows). With Windows at least, your best bet is to generate the public/private SSH keys separately (e.g. PuTTYGen) and place them in the vagrant home directory with the following filenames: `jenkins-master-id_rsa` and `jenkins-master-id_rsa.pub`. Make sure PuTTYGen is configured similar to how ssh-keygen is configured in `create-jenkins-keys.sh`.

## What is built?

The demo will build the following Virtual Machines:
* **vault-server**: A single Vault server
* **consul-{1-3}-server**: A cluster of 3 Consul servers within a single Datacenter
* **jenkins-master**: A single server running a Jenkins master, with Consul and Vault agents configured and running on it.
* **jenkins-worker**: A single, virtually bare-bones server, used as a Jenkins worker.

## Provisioning scripts
The following provisioning scripts will be run by Vagrant:
* install-consul.sh: Automatically installs and configures Consul 1.6.2 (open source) on each of the consul-{1-3}-server VMs. A flag allows it to configure a consul client on the Vault VM too.
* install-vault.sh: Automatically installs and configures Vault (open source) on the Vault server.
* install-jenkins-master.sh: Install Jenkins application on the master. Minor configuration tweaks to **reduce** security to enable the automated Jenkins configuration script to run later on.
* install-jenkins-worker.sh: Create a Jenkins user on the worker node for the master to SSH on to. Drop the public key into the authorized_keys file for the Jenkins user.
* install-vault-agent-master.sh: Deploys Vault binary onto the Jenkins master, with auto-auth configured for the Vault agent.
* install-vault-agent-worker.sh: Deploys Vault binary onto the Jenkins worker, with bare bones configuration for the Vault CLI to communicate to the Vault server.
* create-jenkins-keys.sh: A simple script to run on the host machine to generate an SSH key for the Jenkins user. This is later distributed onto the Jenkins Master and the public key distributed onto the Jenkins Worker.

## Additional files
The following additional files are also included and will need to be run manually (see "How to get started"):
* 0-init-vault.sh: Needs to be run as a manual step to initialise and unseal Vault and login as root token. Run on vault-server
* 1-jenkins-create-master-approle.sh: Creates the approle for Jenkins Master to use. Writes this to vagrant working directory for the Jenkins master to then pick up.
* 2-app1-policy-role-and-secret.sh: Create another AppRole for the Jenkins worker to use, on a supposed build job for an imaginary "app1" application.
* config-jenkins.sh: Creates a Jenkins Credential that Jenkins pipelines can use to access the Jenkins worker node and configures jobs on the Jenkins server (Needs to be run as a manual step once Jenkins's "Getting Started" screen has been followed on the [Jenkins UI](http://10.0.0.14:8080)).

## How to get started
Once Vagrant and Virtualbox are installed, to get started just run the following command within the code directory:
```
vagrant up
```
Once vagrant has completely finished, run the following to SSH onto the vault server
```
vagrant ssh vault-server
```
Once SSH'd onto vault-server, run the following commands in sequence:
```
cp /vagrant/{0,1,2,3,4,5}*.sh . ;
chmod 744 {0,1,2,3,4,5)*.sh ;
./0-init-vault.sh ;
```
This will create a file called vault.txt in the directory you run the script in. The file contains a single Vault unseal key and root token, in case you wish to seal or unseal vault in the future. Of course, in a real-life scenario these files should not be generated automatically and not be stored on the vault server.

You can then simply run each script following `0-init-vault.sh` in numerical order to configure Vault's AppRoles for both Jenkins Master and the demo pipelines to use on the worker.

Once everything is built, you should also be able to access the following UIs at the following addresses:

* Jenkins Master: http://10.0.0.14:8080
* Consul UI: http://10.0.0.11:7500/ui/

**EXTRA STEPS FOR JENKINS**

* There are some manual steps to configuring Jenkins in the demo. Once Vagrant is completely finished, and you have run the scripts on the Vault server listed above, access Jenkins UI on http://10.0.0.14:8080 and perform the following:
1. Enter the initial admin password (can be found by running `vagrant ssh jenkins-master` and then `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`)
2. Choose to install suggested plugins (none of these are really necessary for the demo, though).
3. Rather than create a new admin user, just click "Continue as admin" on the next screen, followed by "Save and Finish" and "Start using Jenkins".
4. Whilst still ssh'd onto the Jenkins Master, perform the following:
```
cp /vagrant/config-jenkins.sh . ;
chmod 744 config-jenkins.sh ;
sudo ./config-jenkins.sh
```
This will configure Credentials and Jobs on the Jenkins server ready to perform the demo (sudo is necessary on the last step to access the initialAdminPassword on Jenkins's filesystem).

If you're having problems, then check your Virtualbox networking configurations. They should be set to the default of NAT. If problems still persist then you might be able to access the UIs via the port forwarding that has been set up- check the Vagrantfile for these ports.

## Support
No support or guarantees are offered with this code. It is purely a demo.

## Kudos/Thanks
- Consul and Vault configuration scripts are based on Iain Gray's [Vault-DR-Vagrant](https://github.com/iainthegray/vault-dr-vagrant) repo. Those scripts were used in this demo with kind permission.

## Future Improvements
* Use Docker containers instead of VMs.
* Other suggested future improvements very welcome.
