# Rakefile for Imint
require 'warbler'
require 'erb'
require 'yaml'
require 'rake'
require 'rake/clean'

WARF = "imint.war"
MANI = "config/MANIFEST.MF"
DIR  = File.expand_path(File.dirname(__FILE__))
EXTR = "#{DIR}/extract"

CLOBBER << WARF
CLOBBER << MANI
CLEAN.include("extract/*")

def version(version)
  fm = File.new(MANI,'w')
  fm << ERB.new(File.read("#{MANI}.erb")).result(binding)
  fm.close
end

Warbler::Task.new

task :default => [:test]

desc "Get additional jar files" # ----------------------------------------
task :getjars do
  [ "lib/oimclient.jar", "lib/commons-logging.jar", "lib/eclipselink.jar",
    "lib/jrf-api.jar",   "lib/wlfullclient.jar",    "lib/spring.jar"
  ].each do |f|
    puts "file: #{f}"
    %x( [ -a #{f} ] || curl --insecure https://agoracon.at/misc/deve/imint/#{f} -o #{f} )
  end
end

desc "Run tests" # -------------------------------------------------------
task :test do
  ruby "test/test_imint.rb"
end

desc "Create project war file and set version number" # ------------------
task :build, :version do |t,args|
  version args[:version]
  Rake::Task["war"].reenable
  Rake::Task["war"].invoke
end 

desc "Start web server on port 8080" # -----------------------------------
task :server do
  sh "rackup -p 8080"
end

desc "Deploy app" # ------------------------------------------------------
task :deploy, :env do |t,args|
  env = (YAML.load_file('config/environment.yml'))[args[:env]]
  sh "scp #{WARF} #{env['user']}@#{env['server']}:#{env['deploy_dir']}/"
  sh "ssh #{env['user']}@#{env['server']} -t '/bin/bash -l -c \"idm ; deploy imint\"'"
end

desc "Extract war" # -----------------------------------------------------
task :extract do
  sh "rm -Rf #{EXTR}; mkdir #{EXTR}"
  sh "unzip  -q #{DIR}/#{WARF} -d #{EXTR}"
end

