require 'minitest/spec'
require 'minitest/autorun'
require 'rack/test'

class MyAppTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    java::lang.System.setProperty('APPSERVER_TYPE','wls')
    java::lang.System.setProperty('OIM_CLIENT_HOME','.')
    java::lang.System.setProperty('java.security.auth.login.config','config/authwl.conf')

    require 'lib/commons-logging.jar'
    require 'lib/eclipselink.jar'
    require 'lib/spring.jar'
    require 'lib/wlfullclient.jar'
    require 'lib/jrf-api.jar'
    require 'lib/oimclient.jar'

    require 'lib/imint/imint_app'

    Imint::ImintApp
  end

  $stmp = Time.new.strftime("%Y%m%d-%H%M%S")

  $user_name, $user_guid = "TIGER#{$stmp}"   , ""
  $org_name,  $org_guid  = "DWP_TEST#{$stmp}", ""
  
  ## entitlements -----------------------------------------------------
  ##
  # get entitlements
  #
#  def test_user_get_entitlements
#   
#    # NOTE: in order for this one to work, you have to have entitlements assigned for this user
#    # get all user entitlements
#    get '/user/21/entitlement'
#    assert (last_response.status == 200), "Get specific user entitlement: response is not 200"
# 
#    # get specific user entitlement
#    # NOTE: in order for this one to work, you have to have entitlements assigned for this user
#    get '/user/21/entitlement/2'
#    assert (last_response.status == 200), "Get user entitlement: response is not 200"
#
#    # revoke user entitlement
#    # NOTE: in order for this one to work, you have to have entitlements assigned for this user
#    put '/user/41/entitlement/2'
#    assert (last_response.status == 200), "Revoke user entitlement: response is not 200"
#  end



#  ## user object tests -----------------------------------------------------
#  ##
#  # add user
#  #
  def test_user_features
    
    # create new user
    post '/user', "{ \"First Name\": \"Tom\", \"Last Name\": \"#{$user_name}\", \"User Login\": \"#{$user_name}\", \"act_key\": 1, \"Role\": \"Full-Time\" }"
    assert (last_response.status == 200), "Create user: response is not 200"
 
    # get user with Last Name "$user_guid"
    get "/user?Last%20Name=#{$user_name}"
    $user_guid = JSON::parse(last_response.body)[0]['usr_key']
    assert (last_response.body.size > 50), "Get user by name: response too small for valid data"

    # modify user with guid defined in @guid variable
    put "/user/#{$user_guid}", '{"Fax": "12345", "Description": "User Description"}'
    assert (last_response.status == 200), "Put user (modify): response is not 200"
 
    # get user with uid defined in $user_guid variable
    get "/user/#{$user_guid}"
    assert (last_response.body.size > 50), "Get user by id: response too small for valid data"

    # change password for user with guid defined in $user_guid variable
    put "/user/#{$user_guid}/password", '{"password": "Montag14", "notify_racf": "false"}'
    assert (last_response.status == 200), "Response is not 200"
 
    # get user with uid defined in $user_name variable
    get "/#{$user_name}"
    assert (last_response.body.size > 50), "Get user by username: response too small for valid data"

    ## change password for user with user login defined in $user_name variable
    put "/#{$user_name}/password", '{"password": "Montag15", "notify_racf": false}'
    assert (last_response.status == 200), "Response is not 200"
 
    # get all users
    get '/user'
    assert (last_response.body.size > 50), "Get all users: Response too small for valid data"

    # get available user attributes
    get '/user/attributes'
    assert (last_response.body.size > 50), "Get user attributes: Response too small for valid data"
  
    # delete user with uid defined in @guid variable
    delete "/user/#{$user_guid}"
    assert (last_response.status == 204), "Response is not 204"
  end


  ## organization object tests -----------------------------------------------------
  def test_organization_features

    # get organization with guid "1"
    post '/organization', "{ \"Organization Name\": \"#{$org_name}\", \"parent_key\": 1, \"Organization Customer Type\": \"Company\" }"
    assert (last_response.status == 200), "Create organization: response is not 200"

    # get organization by name
    get "/organization?Organization%20Name=#{$org_name}"
    assert (last_response.body.size > 50), "Get organization by name: response too small for valid data"

    # get organization with guid $org_guid
    get "/organization/#{$org_guid}"
    assert (last_response.body.size > 50), "Get organization by id: response too small for valid data"

    # get all organizations
    get '/organization'
    assert (last_response.body.size > 50), "Get all organizations: response too small for valid data"

    # get organizations available attributes
    get '/organization/attributes'
    assert (last_response.body.size > 50), "Get organization attribute names: response too small for valid data"
  end

  ### delete organization
  ###def test_organization_delete
  ###  delete '/organization/23'
  ###  assert (last_response.status == 200), "Response is not 200"
  ###end

  # role object tests -------------------------------------------------------------
  def test_role_features

    # get members of role with guid 4
    get '/role/3/members'
    assert (last_response.status == 200), "Get all members of role id 3: response is not 200"

    # get available role attributes
    get '/role/attributes'
    assert (last_response.body.size > 50), "Get available role attributes: response to small for valid data"

    # get all roles
    get '/role'
    assert (last_response.body.size > 50), "Get all roles: response to small for valid data"

    # get role with guid "3"
    get '/role/3'
    assert (last_response.body.size > 50), "Get role with id 3: response to small for valid data"
  end

end

