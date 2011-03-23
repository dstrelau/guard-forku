# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "guard-forku"
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dean Strelau"]
  s.email       = ["dean@mintdigital.com"]
  s.homepage    = "https://github.com/mintdigital/guard-forku"
  s.summary     = %q{A Guard that forks before running tests}
  s.description = <<-DESC
See https://github.com/guard/guard and
https://gitub.com/mintdigital/guard-forku for more.
DESC

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency 'guard', '~> 0.3.0'
end
