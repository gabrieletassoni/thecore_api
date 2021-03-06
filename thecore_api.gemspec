$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "thecore_api/version"

# Describe your s.add_dependency and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "thecore_api"
  s.version     = ThecoreApi::VERSION
  s.authors     = ["Gabriele Tassoni"]
  s.email       = ["gabrieletassoni@taris.it"]
  s.homepage    = "https://www.taris.it"
  s.summary     = "Taris API."
  s.description = "The base of all the apis."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # -----------------------------------------------------------------------------------------------
  # API
  # API: http://fancypixel.github.io/blog/2015/01/28/react-plus-flux-backed-by-rails-api/
  s.add_dependency 'thecore', "~> 1.0"
  # s.add_dependency 'rails-api' merged into rails 5
  s.add_dependency 'ransack', "~> 2.0"
  # s.add_dependency 'active_model_serializers', "~> 0.9.0"
  s.add_dependency 'active_hash_relation', "~> 1.4"
  s.add_dependency 'rack-cors', "~> 1.0"
  s.add_dependency 'therubyracer', "~> 0.12"
  # -----------------------------------------------------------------------------------------------

  # s.add_development_dependency "sqlite3"
end
