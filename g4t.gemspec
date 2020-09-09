Gem::Specification.new do |s|
s.name        = "G4t"
s.version     = "1.0"
s.date        = "2020-09-08"
s.summary     = "git"
s.description = "A simple cli app to make the git commands more easy to you, commit, push and etc."
s.authors     = ["freazesss"]
s.email       = "freazesss@gmail.com"
s.files       = ["lib/g4t.rb"]
s.homepage    = "https://github.com/freazesss/g4t"
s.license     = "MIT"
s.executables = ["g4t"]
s.add_dependency('os', '~> 1.1.1')
s.add_dependency('tty-prompt', '~> 0.22.0')
end
