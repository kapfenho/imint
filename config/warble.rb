Warbler::Config.new do |config|

  config.manifest_file = "config/MANIFEST.MF"
  config.script_files  = [ "config/init.rb" ]

  config.excludes = FileList["config/*.erb"]
  config.excludes << "config/environment.*"
  config.excludes << "config/*.example"
  config.excludes << "config/imint.yml"
  config.excludes << "config/init.rb"
  config.excludes << "config/warble.rb"
  config.excludes << "*.sh"

  # shipped with jrf
  config.excludes << "lib/commons-logging.jar"
  config.excludes << "lib/eclipselink.jar"
  config.excludes << "lib/jrf-api.jar"
  config.excludes << "lib/spring.jar"
  config.excludes << "lib/wlfullclient.jar"

end
