require_relative 'includer'
require_relative 'user_controller'
require_relative 'organization_controller'
require_relative 'role_controller'

module Imint

  class OIMController
  
    attr_accessor :client, :user, :org, :role
  
    def initialize
      @svc, @atts = nil, nil
    end
  
    def connect(url, username, password)
      ctxFactory = "weblogic.jndi.WLInitialContextFactory"
      env = java.util.Hashtable.new
      env.put(JClient::OIMClient::JAVA_NAMING_FACTORY_INITIAL, ctxFactory)
      env.put(JClient::OIMClient::JAVA_NAMING_PROVIDER_URL, url)
  
      client = Java::OracleIamPlatform::OIMClient.new(env)
      client.login(username, password)
  
      @user = UserController.new(client)
      @org  = OrganizationController.new(client)
      @role = RoleController.new(client)
    end
  
    def close
      client.close
    end

  end
end

