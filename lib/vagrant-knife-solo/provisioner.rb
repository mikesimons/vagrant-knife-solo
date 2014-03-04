require 'open3'
require 'chef/knife/solo_bootstrap'

module VagrantPlugins::KnifeSolo
  class KnifeSoloError < ::Vagrant::Errors::VagrantError
    error_namespace("vagrant.provisioners.knife_solo")
  end

  class Provisioner < Vagrant.plugin('2', :provisioner)
    def provision
      @logger = Log4r::Logger.new("vagrant::provisioners::knife-solo")

      opts = {
        :ssh_user => (config.username || @machine.ssh_info[:username]).to_s,
        :ssh_port => (config.ssh_port || @machine.ssh_info[:port]).to_s,
        :identity_file => (config.identity_file || @machine.ssh_info[:private_key_path].first).to_s,
        :ssh_host => (config.hostname || @machine.ssh_info[:host]).to_s,
        :chef_path => (config.chef_path || '.').to_s,
        :host_key_verify => false,
        :log_level => :info,
        :verbosity => 0
      }

      Chef::Config[:knife][:bootstrap_version] = (config.bootstrap_version).to_s unless config.bootstrap_version.nil?

      ENV['PATH'] = [
        File.join(File.dirname(__FILE__), '..', '..', 'bin'),
        ENV['PATH']
      ].join(File::PATH_SEPARATOR)

      hostname = config.hostname || @machine.config.vm.hostname

      Dir.chdir opts[:chef_path] do
        args = [
          [opts[:ssh_user], opts[:ssh_host]].compact.join('@')
        ]

        args.push File.join("nodes", "#{hostname}.json") unless hostname.empty?

        solo = Chef::Knife::SoloBootstrap.new args
        solo.ui = UiProxy.new(@machine.ui)

        # We get debug output without these :(
        Chef::Config[:verbosity] = opts[:verbosity]
        Chef::Config[:log_level] = opts[:log_level]

        solo.config = opts
        solo.configure_chef
        solo.class.load_deps

        begin
          solo.run
        rescue Exception => error
          raise error unless error.message =~ /^chef-solo failed/
          @machine.ui.error("knife_solo provisioner failed!")
          @machine.ui.error("Please see the output immediately above for details")
          raise KnifeSoloError, :fail
        end
      end
    end

    private

    class UiProxy
      def initialize ui
        @ui = ui
      end

      def stdout
        self
      end

      def msg message
        @ui.info(message)
      end

      # Not perfect but it'll do for starters.
      # Sometimes [default] appears mid-line (apt output seems prone)
      def << message
        message.each_line do |line|
          @ui.info(line, :new_line => false)
        end
      end

      def method_missing(method, *args, &block)
        @ui.send(method, *args, &block)
      end
    end

  end
end
