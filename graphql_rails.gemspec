
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphql_rails/version"

Gem::Specification.new do |spec|
  spec.name          = 'graphql_rails'
  spec.version       = GraphqlRails::VERSION
  spec.authors       = ['Povilas Jurčys']
  spec.email         = ['po.jurcys@gmail.com']

  spec.summary       = %q{Rails style structure for GraphQL API.}
  spec.homepage      = 'https://github.com/samesystem/graphql_rails'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'graphql', '~> 2'
  spec.add_dependency 'activesupport', '>= 4'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rails', '~> 6'
end
