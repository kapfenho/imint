require 'java'
require 'securerandom'

#pfix = "../"
#require_relative "#{pfix}/commons-logging.jar"
#require_relative "#{pfix}/eclipselink.jar"
#require_relative "#{pfix}/spring.jar"
#require_relative "#{pfix}/wlfullclient.jar"
#require_relative "#{pfix}/jrf-api.jar"
#require_relative "#{pfix}/oimclient.jar"

module Imint

  module JUser
    include_package "oracle.iam.identity.usermgmt.api"
    include_package "oracle.iam.identity.usermgmt.dao"
    include_package "oracle.iam.identity.usermgmt.utils"
    include_package "oracle.iam.identity.usermgmt.vo"
    include_package "oracle.iam.identity.exception"
    include_package "oracle.iam.platform.authz.exception"
  end
  module JOrg
    include_package "oracle.iam.identity.orgmgmt.api"
    include_package "oracle.iam.identity.orgmgmt.utils"
    include_package "oracle.iam.identity.orgmgmt.vo"
    include_package "oracle.iam.identity.exception"
  end
  module JRole
    include_package "oracle.iam.identity.rolemgmt.api"
    include_package "oracle.iam.identity.rolemgmt.utils"
    include_package "oracle.iam.identity.rolemgmt.vo"
    include_package "oracle.iam.identity.exception"
  end
  module JClient
    include_package "oracle.iam.platform"
    include_package "oracle.iam.platform.authz.exception"
    include_package "oracle.iam.platform.entitymgr.vo"
  end
  module JProv
    include_package "oracle.iam.provisioning.api"
    include_package "oracle.iam.provisioning.vo"
    include_package "oracle.iam.provisioning.exception"
    include_package "oracle.iam.platform.authopss.exception"
    include_package "oracle.iam.platform.authz.exception"
  end
  
  java_import("java.util.HashSet") { |pkg, name| "J" + name }
  java_import("java.util.HashMap") { |pkg, name| "J" + name }
  
  java_import javax.naming.NamingException
  java_import javax.security.auth.login.LoginException

end

