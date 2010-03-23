require 'rubygems'
require 'rake'

PACKAGE_NAME    = "snmpdumper"
PACKAGE_VERSION = "0.0.3"
DEPENDENCIES = [
  ["snmp", "1.0.2" ], 
  ["builder", "2.1.2"]
]

SOURCE_FILES = FileList.new do |fl|
  [ "bin", "lib", "test" ].each do |dir|
    fl.include "#{dir}/**/*"
  end
  fl.include "Rakefile"
end

PACKAGE_FILES = FileList.new do |fl|
  fl.include "README"
  fl.include "LICENSE"
  fl.include SOURCE_FILES
end

desc "Default task"
task :default => [ :package ]

desc "Clean generated files"
task :clean do
  rm_rf "pkg"
end

package_name = "#{PACKAGE_NAME}-#{PACKAGE_VERSION}"
package_dir = "pkg"
package_dir_path = "#{package_dir}/#{package_name}"

gem_file = "#{package_name}.gem"

task :gem  => "#{package_dir}/#{gem_file}"

desc "Build all packages"
task :package => [ :gem ]

directory package_dir

file package_dir_path do
  mkdir_p package_dir_path rescue nil
  PACKAGE_FILES.each do |fn|
    f = File.join( package_dir_path, fn )
    if File.directory?( fn )
      mkdir_p f unless File.exist?( f )
    else
      dir = File.dirname( f )
      mkdir_p dir unless File.exist?( dir )
      rm_f f
      safe_ln fn, f
    end
  end
end

file "#{package_dir}/#{gem_file}" => SOURCE_FILES + [ package_dir ] do
  spec = Gem::Specification.new do |s|
    s.name = PACKAGE_NAME
    s.version = PACKAGE_VERSION
    s.platform = Gem::Platform::RUBY
    s.date = Time.now
    s.summary = "Dumps SNMP walk output in different format."
    s.description = "Dump snmp walks in various formats"
    s.require_paths = [ 'lib' ]
    s.bindir = 'bin'
    s.executables << 'snmpdumper'
    s.files = %w[README LICENSE]
    [ 'lib/**/*', 'test/*' ].each do |dir|
      s.files += Dir.glob( dir ).delete_if { |item| item =~ /^\./ }
    end
    s.author = "Sebastian de Castelberg"
    s.email = 'snmpdumper@kpricorn.org'
    s.homepage = 'http://github.com/sdecastelberg/snmpdumper'
    DEPENDENCIES.each {|dep| s.add_dependency dep[0], dep[1] }
  end
  Gem::Builder.new(spec).build
  mv gem_file, "#{package_dir}/#{gem_file}"
end

task :install => :package do
  `gem install #{package_dir_path}.gem`
end

task :uninstall do
  `gem uninstall #{PACKAGE_NAME} -v #{PACKAGE_VERSION}`
end
