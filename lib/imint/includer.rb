require 'java'
require 'securerandom'

module Imint

  module JUser
    include_package "oracle.iam.identity.usermgmt.api"
    include_package "oracle.iam.identity.usermgmt.dao"
    include_package "oracle.iam.identity.usermgmt.utils"
    include_package "oracle.iam.identity.usermgmt.vo"
    include_package "oracle.iam.identity.exception"
    include_package "oracle.iam.platform.authz.exception"
    include_package "oracle.iam.reconciliation.vo"
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
  
  java_import("java.util.HashSet") { |pkg, name| "J" + name }
  java_import("java.util.HashMap") { |pkg, name| "J" + name }
  
  java_import javax.naming.NamingException
  java_import javax.security.auth.login.LoginException

end

