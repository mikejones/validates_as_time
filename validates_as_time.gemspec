require 'rubygems'

SPEC = Gem::Specification.new do |s|
  s.name = 'validates_as_time'
  s.version = '0.9'
  s.author = 'Lawrence Pit'
  s.email = 'lawrence.pit@gmail.com'
  s.homepage = 'http://github.com/lawrencepit/validates_as_time'
  s.platform = Gem::Platform::RUBY
  s.summary = "A rails plugin to easily validate date time attributes in your models"
  readmes = FileList.new('*') do |list|
    list.exclude(/(^|[^.a-z])[a-z]+/)
    list.exclude('TODO')
  end.to_a  
  s.files = FileList['lib/**/*', 'test/**/*', 'Rakefile', 'init.rb'].to_a + readmes
  s.require_path = "lib"
  s.autorequire = "validates_as_time"
  s.has_rdoc = true
  s.extra_rdoc_files = readmes
  s.rdoc_options += [
    '--title', 'validates_as_time',
    '--main', 'README.rdoc',
    '--line-numbers',
    '--inline-source'
   ]
  s.test_files = FileList['test/**/*_test.rb'].to_a
end