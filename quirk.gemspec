Gem::Specification.new do |s|
  s.name        = 'quirk'
  s.version     = '0.0.5'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hugh Bien']
  s.email       = ['hugh@hughbien.com']
  s.homepage    = 'https://github.com/hughbien/quirk'
  s.summary     = "Track good and bad habits"
  s.description = 'Command line tool for tracking good/bad habits, ' +
                  'data stored in plaintext.'
 
  s.required_rubygems_version = '>= 1.3.6'
  s.add_development_dependency 'minitest'
  s.add_dependency 'colorize'
 
  s.files        = Dir.glob('*.md') + Dir.glob('bin/*') + Dir.glob('lib/*')
  s.bindir       = 'bin'
  s.executables  = ['quirk']
end
