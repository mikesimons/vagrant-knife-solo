module VagrantPlugins
  module KnifeSolo
    lib_path = Pathname.new(File.expand_path("../vagrant-knife-solo", __FILE__))
    autoload :Errors, lib_path.join("errors")
  end
end

require 'vagrant-knife-solo/plugin'
