#!/usr/bin/env rake
# -*- Ruby -*-
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'
require 'rake/extensiontask'
require 'rake/javaextensiontask'

$:.push File.expand_path("../lib", __FILE__)
require "ruby-debug-base/version"

ROOT_DIR = File.dirname(__FILE__)

# ------- Default Package ----------
COMMON_FILES = FileList[
  'AUTHORS',
  'CHANGES',
  'LICENSE',
  'README',
  'Rakefile',
]                        

CLI_TEST_FILE_LIST = FileList['test/cli/commands/unit/*.rb',
                              'test/cli/commands/*_test.rb', 
                              'test/cli/**/*_test.rb', 
                              'test/test-*.rb'] 
CLI_FILES = COMMON_FILES + FileList[
  "cli/**/*",
  'ChangeLog',
  'bin/*',
  'doc/rdebug.1',
  'test/rdebug-save.1',
  'test/**/data/*.cmd',
  'test/**/data/*.right',
  'test/**/example/*.rb',
  'test/config.yaml',
  'test/**/*.rb',
  'rdbg.rb',
   CLI_TEST_FILE_LIST
]

BASE_TEST_FILE_LIST = FileList['test/base/*.rb']

BASE_FILES = COMMON_FILES + FileList[
  'ext/breakpoint.c',
  'ext/extconf.rb',
  'ext/ruby_debug.c',
  'ext/ruby_debug.h',
  'ext/win32/*',
  'lib/ruby-debug-base.rb',
  'lib/ruby-debug-base/version.rb',
  BASE_TEST_FILE_LIST,
]

ext = File.join(ROOT_DIR, 'ext')

desc "Test everything."
Rake::TestTask.new(:test) do |t|
  t.libs += %W(#{ROOT_DIR}/lib #{ROOT_DIR}/cli)
  t.libs << ext if File.exist?(ext)
  t.test_files = CLI_TEST_FILE_LIST
  t.options = '--verbose' if $VERBOSE
  t.ruby_opts << "--debug" if defined?(JRUBY_VERSION)
end

task :test => :test_base if File.exist?(ext)

desc "Test ruby-debug-base."
Rake::TestTask.new(:test_base) do |t|
  t.libs += ['./ext', './lib']
  t.test_files = FileList[BASE_TEST_FILE_LIST]
  t.options = '--verbose' if $VERBOSE
  t.ruby_opts << "--debug" if defined?(JRUBY_VERSION)
end

if defined?(JRUBY_VERSION)
  task :test_base => 'jruby:compile:java'
else
  task :test_base => :compile
end

desc "Test everything - same as test."
task :check => :test

desc "Create a GNU-style ChangeLog via svn2cl"
task :ChangeLog do
  system('git log --pretty --numstat --summary     | git2cl >     ChangeLog')
  system('git log --pretty --numstat --summary ext | git2cl > ext/ChangeLog')
  system('git log --pretty --numstat --summary lib | git2cl > lib/ChangeLog')
end

# Base GEM Specification
base_spec = Gem::Specification.new do |spec|
  spec.name = "ruby-debug-base"
  
  spec.homepage = "http://rubyforge.org/projects/ruby-debug/"
  spec.summary = "Fast Ruby debugger - core component"
  spec.description = <<-EOF
ruby-debug is a fast implementation of the standard Ruby debugger debug.rb.
It is implemented by utilizing a new Ruby C API hook. The core component 
provides support that front-ends can build on. It provides breakpoint 
handling, bindings for stack frames among other things.
EOF

  spec.version = Debugger::VERSION

  spec.author = "Kent Sibilev"
  spec.email = "ksibilev@yahoo.com"
  spec.platform = Gem::Platform::RUBY
  spec.require_path = "lib"
  spec.extensions = ["ext/extconf.rb"]
  spec.files = BASE_FILES.to_a  

  spec.required_ruby_version = '>= 1.8.2'
  spec.date = Time.now
  spec.rubyforge_project = 'ruby-debug'
  spec.add_dependency('linecache', '>= 0.3')
  spec.add_development_dependency('rake-compiler')

  spec.test_files = FileList[BASE_TEST_FILE_LIST]
  
  # rdoc
  spec.has_rdoc = true
  spec.extra_rdoc_files = ['README', 'ext/ruby_debug.c']
end

cli_spec = Gem::Specification.new do |spec|
  spec.name = "ruby-debug"
  
  spec.homepage = "http://rubyforge.org/projects/ruby-debug/"
  spec.summary = "Command line interface (CLI) for ruby-debug-base"
  spec.description = <<-EOF
A generic command line interface for ruby-debug.
EOF

  spec.version = Debugger::VERSION

  spec.author = "Kent Sibilev"
  spec.email = "ksibilev@yahoo.com"
  spec.platform = Gem::Platform::RUBY
  spec.require_path = "cli"
  spec.bindir = "bin"
  spec.executables = ["rdebug"]
  spec.files = CLI_FILES.to_a

  spec.required_ruby_version = '>= 1.8.2'
  spec.date = Time.now
  spec.rubyforge_project = 'ruby-debug'
  spec.add_dependency('columnize', '>= 0.1')
  spec.add_dependency('ruby-debug-base', "~> #{Debugger::VERSION}.0")
  
  # FIXME: work out operational logistics for this
  # spec.test_files = FileList[CLI_TEST_FILE_LIST]

  # rdoc
  spec.has_rdoc = true
  spec.extra_rdoc_files = ['README']
end

Gem::PackageTask.new(base_spec) {}
Gem::PackageTask.new(cli_spec) {}

Rake::ExtensionTask.new('ruby_debug', base_spec) do |t|
  t.ext_dir = "ext"
end

task :default => :test

desc "Remove built files"
task :clean do
  cd "ext" do
    if File.exists?("Makefile")
      sh "make clean"
      rm  "Makefile"
    end
    derived_files = Dir.glob(".o") + Dir.glob("*.so")
    rm derived_files unless derived_files.empty?
  end
  rm 'lib/ruby_debug.jar' if File.exists?("lib/ruby_debug.jar")
end

# ---------  RDoc Documentation ------
desc "Generate rdoc documentation"
RDoc::Task.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title    = "ruby-debug"
  # Show source inline with line numbers
  rdoc.options << "--inline-source" << "--line-numbers"
  # Make the readme file the start page for the generated html
  rdoc.options << '--main' << 'README'
  rdoc.rdoc_files.include('bin/**/*',
                          'cli/ruby-debug/commands/*.rb',
                          'cli/ruby-debug/*.rb',
                          'lib/**/*.rb',
                          'ext/**/ruby_debug.c',
                          'README',
                          'LICENSE')
end

namespace :jruby do
  jruby_spec = base_spec.clone
  jruby_spec.platform   = "java"
  jruby_spec.files      = jruby_spec.files.reject {|f| f =~ /^ext/ }
  jruby_spec.files     += ['lib/ruby_debug.jar']
  jruby_spec.extensions = []

  Gem::PackageTask.new(jruby_spec) {}

  Rake::JavaExtensionTask.new('ruby_debug') do |t|
    t.ext_dir = "src"
  end
end
