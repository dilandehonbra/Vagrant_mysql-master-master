Vagrant.configure("2") do |config|
  (1..2).each do |i|


        config.vm.define "dlsproject-#{i}" do |dlsptrd|
        dlsptrd.vm.box = "centos/8"
        dlsptrd.vm.hostname = "NODE0#{i}"
        dlsptrd.vm.network "public_network", ip: "192.168.150.15#{i}",
                bridge: "Qualcomm Atheros QCA9377 Wireless Network Adapter"
        dlsptrd.vm.provision "shell", path: "scriptera.sh"


        config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1

   end
  end
 end
end
