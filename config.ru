require 'rubygems'
require 'bundler/setup'

Bundler.require

if $servlet_context.nil?
  require 'lib/commons-logging.jar'
  require 'lib/eclipselink.jar'
  require 'lib/spring.jar'
  require 'lib/wlfullclient.jar'
  require 'lib/jrf-api.jar'
  require 'lib/oimclient.jar'
end

java::lang.System.setProperty('APPSERVER_TYPE','wls')
java::lang.System.setProperty('OIM_CLIENT_HOME','.')
java::lang.System.setProperty('java.security.auth.login.config','config/authwl.conf')

require 'lib/imint/imint_app'

run Imint::ImintApp


