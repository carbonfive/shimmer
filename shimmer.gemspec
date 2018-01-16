
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "shimmer/version"

Gem::Specification.new do |spec|
  spec.name          = "shimmer"
  spec.version       = Shimmer::VERSION
  spec.authors       = ["Christian Nelson"]
  spec.email         = ["christian@carbonfive.com"]

  spec.summary       = "A headless chrome capybara driver designed for speed."
  spec.description   = "A headless chrome capybara driver designed for speed."
  spec.homepage      = "https://github.com/christiannelson/shimmer"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.2"

  spec.add_dependency "capybara", "~> 2.16"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rubocop", "~> 0.52.1"

  # This would be the ideal way to add dev dependencies, but ends
  # up somehow messing up my chromedriver path. Punting for now, and
  # inserting dev deps in the Gemfile.
  #
  # spec.add_development_dependency "benchmark-ips"
  # spec.add_development_dependency "capybara"
  # spec.add_development_dependency "poltergeist"
  # spec.add_development_dependency "selenium-webdriver"
  # spec.add_development_dependency "pry-byebug"
end
