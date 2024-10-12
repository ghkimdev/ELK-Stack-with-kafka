# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "install/bootstrap.sh"

  ElasticCount = 3
  KafkaCount =3

  (1..ElasticCount).each do |i|

    config.vm.define "elastic0#{i}" do |node|

      node.vm.box               = "generic/ubuntu2004"
      node.vm.box_check_update  = false
      node.vm.box_version       = "4.2.6"
      node.vm.hostname          = "elastic0#{i}.example.com"

      node.vm.network "private_network", ip: "172.16.1.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "elastic0#{i}"
        v.memory  = 6144
        v.cpus    = 2
      end

      node.vm.provider :libvirt do |v|
        v.nested  = true
        v.memory  = 6144
        v.cpus    = 2
      end

    end

  end

  (1..KafkaCount).each do |i|

    config.vm.define "kafka0#{i}" do |node|

      node.vm.box               = "generic/ubuntu2004"
      node.vm.box_check_update  = false
      node.vm.box_version       = "4.2.6"
      node.vm.hostname          = "kafka0#{i}.example.com"

      node.vm.network "private_network", ip: "172.16.1.11#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "kafka0#{i}"
        v.memory  = 4096
        v.cpus    = 2
      end

      node.vm.provider :libvirt do |v|
        v.nested  = true
        v.memory  = 4096
        v.cpus    = 2
      end

    end

  end

end
