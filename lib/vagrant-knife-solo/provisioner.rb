require 'open3'
require 'chef/knife'

module VagrantPlugins::KnifeSolo
  class Provisioner < Vagrant.plugin('2', :provisioner)
    def provision
      @logger = Log4r::Logger.new("vagrant::provisioners::knife-solo")

      opts = {
        :username => config.username || @machine.ssh_info[:username],
        :ssh_port => config.ssh_port || @machine.ssh_info[:port],
        :identity_file => config.identity_file || @machine.ssh_info[:private_key_path].first,
        :hostname => config.hostname || @machine.config.vm.hostname,
        :bootstrap_version => config.bootstrap_version,
        :chef_path => '.'
      }

      opts.each do |k, v|
        opts[k] = v.to_s
      end

      ENV['PATH'] = [
        File.join(File.dirname(__FILE__), '..', '..', '..', 'bin'),
        ENV['PATH']
      ].join(File::PATH_SEPARATOR)

      parts = [
        %w{solo bootstrap},
        [opts[:username], @machine.ssh_info[:host]].compact.join('@'),
        [ '-i', opts[:identity_file] ],
        [ '--ssh-port', opts[:ssh_port]]
      ]

      parts.push ['--bootstrap-version', opts[:bootstrap_version]] if opts[:bootstrap_version]

      parts.push "nodes/#{opts[:hostname]}.json"

      @logger.info("Running knife-solo")
      @logger.debug(parts.flatten.join(' '))

      Dir.chdir opts[:chef_path] do
        ENV['PATH'] =
        result = Chef::Knife.run(parts.flatten)
      end

      puts result

      #if config.abort_on_nonzero && !result.exit_code.zero?
      #  raise VagrantPlugins::KnifeSolo::Errors::NonZeroStatusError.new(config.inline, result.exit_code)
      #end

    end

    private

    def chunk_line_iterator stream
      begin
        until (chunk = stream.readpartial(1024)).nil? do
          chunk.each_line do |outer_line|
            outer_line.each_line("\r") do |line|
              yield line
            end
          end
        end
      rescue EOFError
        # NOP
      end
    end

    def jailbreak *cmd
      Open3::popen3({ 'PATH' => ENV['VAGRANT_PATH_SAVED'], 'GEM_HOME' => nil, 'GEM_PATH' => nil }, *(cmd.flatten)) do |input, output, error, wait|
        threads = [wait]
        { :out => output, :err => error }.each do |key, stream|
          threads.push(::Thread.new do
            chunk_line_iterator stream do |line|
              next if line.strip.empty?
              m = key == :out ? :info : :error
              @machine.ui.send(m, line)
            end
          end)
        end

        threads.each do |thread|
          thread.join
        end
      end
    end
  end
end
