# ==============================================================================
# encrypted gate
# ==============================================================================
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "encrypted_gate/version"

Gem::Specification.new do |spec|
  spec.name          = "encrypted_gate"
  spec.version       = EncryptedGate::VERSION
  spec.authors       = ["Satohiro Wakabayashi"]
  spec.email         = ["wakabayashi@twogate.com"]

  spec.summary       = "Encrypt table columns"
  spec.description   = "Encrypt columns for secure database storage"
  spec.homepage      = "https://github.com/twogate"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
