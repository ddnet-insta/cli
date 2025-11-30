# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'ddnet_insta_cli'
  s.version     = '0.0.1'
  # TODO: name not unique enuf??
  # s.executables = %w[cli]
  s.summary     = 'ddnet-insta C++ code gen tool'
  s.description = <<-DESC
  yes
  DESC
  s.authors     = ['ChillerDragon']
  s.email       = 'ChillerDragon@gmail.com'
  s.files       = [
    'lib/*.rb'
  ].map { |glob| Dir[glob] }.flatten
  s.required_ruby_version = '>= 3.3.5'
  s.add_dependency 'fileutils', '~> 1.6.0'
  s.add_dependency 'os', '~> 1.0.1'
  s.add_dependency 'rspec', '~> 3.9.0'
  s.homepage    = 'https://github.com/ddnet-insta/cli'
  s.license     = 'Unlicense'
  s.metadata['rubygems_mfa_required'] = 'true'
end
