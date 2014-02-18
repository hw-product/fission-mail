$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-mail/version'
Gem::Specification.new do |s|
  s.name = 'fission-mail'
  s.version = Fission::Mail::VERSION.version
  s.summary = 'Fission Mail'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-mail'
  s.description = 'Fission Mail'
  s.require_path = 'lib'
  s.add_dependency 'fission'
  s.add_dependency 'mandrill-api'
  s.add_dependency 'pony'
  s.add_dependency 'mail', '2.5.4'
  s.files = Dir['**/*']
end
