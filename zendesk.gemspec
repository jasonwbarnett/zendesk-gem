# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zendesk/version'

Gem::Specification.new do |spec|
  spec.name          = "zendesk"
  spec.version       = Zendesk::VERSION
  spec.authors       = ["Jason Barnett"]
  spec.email         = ["J@sonBarnett.com"]
  spec.summary       = %q{Yet Another Zendesk API wrapper in Ruby.}
  spec.description   = %q{Yet Another Zendesk API wrapper in Ruby. I wrote this because none of the current API wrappers could do what I needed. I attempted to look at the others to see if I could improve them and submit merge/pull requests but they were extremely complex and a wasted a lot of time.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
