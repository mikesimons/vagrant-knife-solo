module VagrantPlugins::KnifeSolo
  class Config < Vagrant.plugin('2', :config)
    FIELDS = [ :username, :hostname, :ssh_port, :chef_path, :identity_file, :bootstrap_version ]
    attr_accessor *FIELDS

    def initialize
      FIELDS.each do |k|
        send "#{k.to_s}=", UNSET_VALUE
      end
    end

    def finalize!
      FIELDS.each do |k|
        send "#{k.to_s}=", nil if instance_variable_get("@#{k.to_s}") == UNSET_VALUE
      end
    end

    def validate(machine)
      errors = _detected_errors

      # errors << "Some error"

      { 'knife solo provisioner' => errors }
    end
  end
end
