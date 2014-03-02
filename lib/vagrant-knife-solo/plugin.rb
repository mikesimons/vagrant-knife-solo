begin
  require 'vagrant'
rescue LoadError
  raise 'The vagrant-host-shell plugin must be run within Vagrant.'
end

module VagrantPlugins::KnifeSolo
  class Plugin < Vagrant.plugin('2')
    name 'vagrant-knife-solo'
    description <<-DESC.gsub(/^ {6}/, '')
      A provisioner that utilizes knife-solo.
    DESC

    config(:knife_solo, :provisioner) do
      require_relative 'config'
      Config
    end

    provisioner(:knife_solo) do
      require_relative 'provisioner'
      Provisioner
    end
  end
end
