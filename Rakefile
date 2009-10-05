require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "snmpdumper"
    s.version   =   "0.0.1"
    s.author    =   "Sebastian de Castelberg"
    s.email     =   "snmpdumper @nospam@ kpricorn.org"
    s.summary   =   "SNMP Dumper"
    s.files     =   FileList['bin/*', 'lib/*.rb', 'test/*'].to_a
    s.require_path  =   "lib"
    s.autorequire   =   "snmpdumper"
    s.test_files = Dir.glob('tests/*.rb')
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README"]
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

