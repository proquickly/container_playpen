Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/home/vagrant/app/"
  config.vm.provider 'docker' do |docker, override|
    override.vm.box = nil
    docker.build_dir = "."
    #docker.image = "rofrano/vagrant:ubuntu"
    docker.name = "vagrant-docker"
    override.ssh.insert_key = true
    docker.remains_running = true
    docker.has_ssh = true
    docker.privileged = true
    docker.create_args = ['--privileged']
  end
end
