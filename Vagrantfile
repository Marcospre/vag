# -- mode: ruby --
# vi: set ft=ruby :
BOX_IMAGE = "ubuntu/focal64"
BOX_DESKTOP = "gusztavvargadr/ubuntu-desktop"
DOMAIN = "aula104.local"
DNSIP = "192.168.1.100"
LAB = "bind9"

DOMAIN = "aula104.local"
RED = "192.168.1"

$dnsclient = <<-SHELL

  echo -e "nameserver $1\ndomain aula104.local">/etc/resolv.conf
SHELL

$apache = <<-SHELL
  sudo apt update
  sudo apt -y install apache2
SHELL

$nginxserver = <<-SHELL
  apt-get update
  apt-get install -y nginx
SHELL


services = {
  "nginx"   => { :ip => "#{RED}.10", :provision=>$nginxserver,  :port=> "8080" },
  "apache1" => { :ip => "#{RED}.11", :provision=>$apache, :port=> "8081" },
  "apache2" => { :ip => "#{RED}.12", :provision=>$apaches, :port=> "8082" },
}

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

  #apache
  # (1..2).each do |id|
  #   config.vm.define "apache#{id}" do |guest|
  #     guest.vm.provider "virtualbox" do |vb, subconfig|
  #       vb.name = "apache#{id}"
  #       subconfig.vm.hostname = "apache#{id}.#{DOMAIN}"

  #       subconfig.vm.network :private_network, ip: "192.168.1.#{150+id}",  virtualboxintnet: LAB
  #     end
  #     guest.vm.provision "shell", name: "dns-server", path: "enable-bind9.sh", args: DNSIP
  #   end
  # end

   # services 
   services.each_with_index do |(hostname, info), idx|
    config.vm.define hostname do |guest|
      guest.vm.provider :virtualbox do |vb, subconfig|
        vb.name = hostname
        subconfig.vm.hostname = "#{hostname}.#{DOMAIN}"
        subconfig.vm.network :private_network, ip: info[:ip], virtualbox__intnet: LAB
      end
      guest.vm.provision "shell", name: "dns-client \##{idx}", inline: $dnsclient, args: "#{DNSIP} #{DOMAIN}"
      guest.vm.provision "shell", name: "#{hostname}:#{info[:port]}", inline: info[:provision], args:  "#{hostname} #{DOMAIN}"
      guest.vm.network "forwarded_port", guest: 80, host: info[:port]
    end 
  end

  # clients DHCP
  (1..1).each do |id|
    config.vm.define "client#{id}" do |guest|
      guest.vm.provider "virtualbox" do |vb, subconfig|
        vb.name = "client#{id}"
        subconfig.vm.hostname = "client#{id}.#{DOMAIN}"

        subconfig.vm.network :private_network, ip: "192.168.1.#{100+id}",  virtualboxintnet: LAB
      end
      guest.vm.provision "shell", name: "dns-client", inline: $dnsclient, args: "#{DNSIP} #{DOMAIN}"
      guest.vm.provision "shell", name: "testing", inline: <<-SHELL
        dig google.com +short
        dig -x 192.168.1.100 +short
        ping -a -c 1 apache1
        ping -a -c 1 apache2.aula104.local
        curl apache1 --no-progress-meter 
        curl apache2 --no-progress-meter 
        curl nginx --no-progress-meter 
        ping -a -c 1 amazon.com
        #ping -a -c 1 ns2
      SHELL
    end
  end

end