# -- mode: ruby --
# vi: set ft=ruby :
BOX_IMAGE = "ubuntu/focal64"
DOMAIN = "aula104.local"
DNSIP = "192.168.1.100"
LAB = "bind9"

$dnsclient = <<-SHELL

  echo -e "nameserver $1\ndomain aula104.local">/etc/resolv.conf
SHELL

$apache1 = <<-SHELL
  sudo apt update
  sudo apt -y install apache2
SHELL

Vagrant.configure("2") do |config|
  # config general
  config.vm.box = BOX_IMAGE

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 1
    vb.memory = 1024
    vb.customize ["modifyvm", :id, "--groups", "/DNSLAB9"]
  end

  # dns 
  config.vm.define :dns do |guest|
    guest.vm.provider "virtualbox" do |vb, subconfig|
      vb.name = "dns"
      subconfig.vm.hostname = "dns.#{DOMAIN}"
      subconfig.vm.network :private_network, ip: DNSIP,  virtualboxintnet: LAB # ,  name: RED #
    end
    guest.vm.provision "shell", name: "dns-server", path: "enable-bind9.sh", args: DNSIP
  end

  #apache1
  (1..1).each do |id|
    config.vm.define "apache#{id}" do |guest|
      guest.vm.provider "virtualbox" do |vb, subconfig|
        vb.name = "apache#{id}"
        subconfig.vm.hostname = "apache#{id}.#{DOMAIN}"

        subconfig.vm.network :private_network, ip: "192.168.1.#{150+id}",  virtualboxintnet: LAB
      end
      guest.vm.provision "shell", name: "dns-server", path: "enable-bind9.sh", args: DNSIP
    end
  end


  # clients DHCP
  (1..1).each do |id|
    config.vm.define "client#{id}" do |guest|
      guest.vm.provider "virtualbox" do |vb, subconfig|
        vb.name = "client#{id}"
        subconfig.vm.hostname = "client#{id}.#{DOMAIN}"

        subconfig.vm.network :private_network, ip: "192.168.1.#{150+id}",  virtualboxintnet: LAB
      end
      guest.vm.provision "shell", name: "dns-client", inline: $dnsclient, args: DNSIP
      guest.vm.provision "shell", name: "testing", inline: <<-SHELL
        dig google.com +short
        dig -x 192.168.1.100 +short
        #ping -a -c 1 apache1
        #ping -a -c 1 apache2.aula104.local
        # curl apache1 --no-progress-meter 
        # curl apache2 --no-progress-meter 
        # curl nginx --no-progress-meter 
        ping -a -c 1 amazon.com
        #ping -a -c 1 ns2
      SHELL
    end
  end

end