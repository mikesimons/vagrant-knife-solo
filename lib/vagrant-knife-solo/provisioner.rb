require 'open3'
require 'chef/knife/solo_bootstrap'

module VagrantPlugins::KnifeSolo
  class Provisioner < Vagrant.plugin('2', :provisioner)
    def provision
      @logger = Log4r::Logger.new("vagrant::provisioners::knife-solo")

      opts = {
        :ssh_user => (config.username || @machine.ssh_info[:username]).to_s,
        :ssh_port => (config.ssh_port || @machine.ssh_info[:port]).to_s,
        :identity_file => (config.identity_file || @machine.ssh_info[:private_key_path].first).to_s,
        :ssh_host => (config.hostname || @machine.ssh_info[:host]).to_s,
        :bootstrap_version => (config.bootstrap_version).to_s,
        :chef_path => (config.chef_path || '.').to_s,
        :host_key_verify => false,
        :color => true
      }

      opts.delete :bootstrap_version if opts[:bootstrap_version].empty?

      ENV['PATH'] = [
        File.join(File.dirname(__FILE__), '..', '..', 'bin'),
        ENV['PATH']
      ].join(File::PATH_SEPARATOR)

      Dir.chdir opts[:chef_path] do
        solo = Chef::Knife::SoloBootstrap.new [
          [opts[:ssh_user], opts[:ssh_host]].compact.join('@')
        ]


        solo.config = opts
        solo.class.load_deps
        solo.run
      end
    end

    private

    class UiProxy
      def initialize ui
        @ui = ui
      end

      def msg message
        @ui.info("MSG: #{message.to_s}")
      end

      def method_missing(method, *args, &block)
        puts "XXX"
        @ui.send(method, *args, &block)
      end
    end

  end
end
