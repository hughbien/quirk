require File.expand_path('quirk', File.dirname(__FILE__))

task :default => :test

task :test do
  ruby '*_test.rb'
end

task :build do
  `gem build quirk.gemspec`
end

task :clean do
  rm Dir.glob('*.gem')
end

task :push => :build do
  `gem push quirk-#{Quirk::VERSION}.gem`
end
