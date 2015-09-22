lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'capkin/version'

Gem::Specification.new do |s|
  s.name        = 'capkin'
  s.version     = Capkin::VERSION
  s.platform    = Gem::Platform::RUBY

  s.authors     = ['Marcos Piccinini', 'Jorge Fernando']
  s.homepage    = 'http://github.com/fireho/capkin'
  s.email       = 'see@github.com'
  s.description = 'Uploads your apps to Google Play'
  s.summary     = 'Uploads your apps to Google Play'
  s.license     = 'MIT'

  s.executables = ['capkin']
  s.default_executable = 'capkin'

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'thor'
  s.add_dependency 'paint'
  s.add_dependency 'ruby_apk'
  s.add_dependency 'google-api-client', '0.9.pre3'
  s.add_dependency 'googleauth'
end
