module VagrantPlugins::KnifeSolo::Errors

    class VagrantKnifeSoloError < Vagrant::Errors::VagrantError; end

    class NonZeroStatusError < VagrantKnifeSoloError
      def initialize(command, exit_code)
        @command = command
        @exit_code = exit_code
        super nil
      end

      def error_message
        "Command [#{@command}] exited with non-zero status [#{@exit_code}]"
      end

    end
end
