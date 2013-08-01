Gem::Specification.new do |s|
  s.name          = "mongoid-siblings"
  s.version       = "0.1.2"
  s.platform      = Gem::Platform::RUBY
  s.author        = "Douwe Maan"
  s.email         = "douwe@selenight.nl"
  s.homepage      = "https://github.com/DouweM/mongoid-siblings"
  s.summary       = "Easy access to your Mongoid document's siblings."
  s.description   = "mongoid-siblings adds methods to enable you to easily access your Mongoid document's siblings."
  s.license       = "MIT"

  s.files         = Dir.glob("lib/**/*") + %w(LICENSE README.md Rakefile Gemfile)
  s.test_files    = Dir.glob("spec/**/*")
  s.require_path  = "lib"

  s.add_runtime_dependency "mongoid", "~> 3.0"
  
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
