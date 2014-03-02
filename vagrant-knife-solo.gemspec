# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vagrant-knife-solo/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-knife-solo"
  spec.version       = VagrantPlugins::KnifeSolo::VERSION
  spec.authors       = ["Mike Simons"]
  spec.email         = ["msimons@inviqa.com"]
  spec.description   = %q{A knife-solo based vagrant provisioner}
  spec.summary       = %q{A knife-solo based vagrant provisioner}
  spec.homepage      = ""

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "knife-solo"
  spec.add_dependency "chef", "10.20"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
