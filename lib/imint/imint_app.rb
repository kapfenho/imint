require 'yaml'
require 'json/pure'
require 'sinatra/base'
require_relative 'oim_controller'

module Imint

  class ImintApp < Sinatra::Base

    class OIM
      def self.connect()
        conf = YAML.load_file('config/imint.yml')
        # env = ENV['RACK_ENV'] || 'development'

        oim = conf[ENV['RACK_ENV'] || 'development']['oim']
        @@con = OIMController.new
        @@con.connect(oim['url'], oim['user'], oim['password'])
      end
  
      def self.do()
        return @@con
      end
    end

    configure do
      enable :logging
      set :json_encoder, :to_json
      OIM::connect()
    end
 
    # provisioning
    #
    # get all user entitlements
    get '/user/:id/entitlements' do
      ent = OIM::do.prov.get_user_entitlements(params)
      halt 404 if ent.empty? or ent.nil?
      content_type :js
      JSON::pretty_generate ent
    end

    # -> get user entitilement
    get '/user/:id/entitlement/:eid' do
      ent = OIM::do.prov.get_user_entitlements(params)
      halt 404 if ent.nil? or ent.empty?
      halt 404 if ent == Java::OracleIamProvisioningException::UserNotFoundException
      content_type :js
      JSON::pretty_generate OIM::do.prov.parse_entitlements(ent)
    end
    
    # -> revoke user entitlement
    put '/user/:id/entitlement/:eid' do
      ent = OIM::do.prov.revoke_user_entitlement( { :eid => params[:eid], 
                                                    :id => params[:id] } )
      halt 404 if ent.class == IOError
      halt 404 if ent == Java::OracleIamProvisioningException::AccountNotFoundException
      halt 404 if ent == Java::OracleIamProvisioningException::EntitlementNotProvisionedException
    end

    # user      ----------------------------------------
    #
    get '/user/attributes' do
      content_type :js
      JSON::pretty_generate OIM::do.user.list_attributes.sort
    end

    get '/user' do
      if params.size > 0
        params['usr_key'] = params['usr_key'].to_i if params.key?('usr_key')
        users = OIM::do.user.search_for(params)
      else  
        users = OIM::do.user.index
      end
      halt 404 if users.nil? or users.empty?
      content_type :js
      JSON.pretty_generate users
    end
  
    get '/user/:id' do
      users = OIM::do.user.search_for( { 'usr_key' => params[:id] } )
      halt 404 if users.nil? or users.empty?
      content_type :js
      JSON::pretty_generate users
    end
  
    post '/user' do
      data = JSON.parse(request.body.read)
      user = OIM::do.user.create(data)
    end
  
    put '/user/:id' do
      data = JSON.parse(request.body.read)
      OIM::do.user.update(params[:id], data)
    end

    put '/user/:id/password' do
      data = JSON.parse(request.body.read)
      user = OIM::do.user.change_password(params[:id], data)
      data[:is_usr_login => false]
      halt 404 if user.class == Java::OracleIamIdentityException::NoSuchUserException
      halt 401 if user.class == Java::OracleIamPlatformAuthzException::AccessDeniedException
      halt 400 if user.class == Java::OracleIamIdentityException::UserManagerException
    end
   
    get '/login/:usr_login' do
      users = OIM::do.user.search_for( params )
      halt 404 if users.nil? or users.empty?
      content_type :js
      JSON::pretty_generate users
    end

    put '/login/:usr_login/password' do
      data = JSON.parse(request.body.read)
      user = OIM::do.user.change_password(login: params[:usr_login],
                                          data[:password])
      halt 404 if user.class == Java::OracleIamIdentityException::NoSuchUserException
      halt 401 if user.class == Java::OracleIamPlatformAuthzException::AccessDeniedException
      halt 400 if user.class == Java::OracleIamIdentityException::UserManagerException
    end

    delete '/user/:id' do
      halt 500 unless OIM::do.user.delete params[:id]
      204
    end

    # role              ------------------------------------
    #
    get '/role/attributes' do
      content_type :js
      JSON::pretty_generate OIM::do.role.list_attributes.sort
    end

    get '/role' do
      if params.size > 0
        params['Role Key'] = params['Role Key'].to_i if params.key?('Role Key')
        roles = OIM::do.role.search_for(params)
      else
        roles = OIM::do.role.index
      end
      halt 404 if roles.nil? or roles.empty?
      content_type :js
      JSON::pretty_generate roles
    end
    
    get '/role/:id' do
      role = OIM::do.role.search_for( {'Role Key' => params[:id]} )
      halt 404 if role.nil? or role.empty?
      content_type :js
      JSON::pretty_generate role
    end

    get '/role/:id/members' do
      users = OIM::do.role.get_members(params)
      halt 404 if users.nil? or users.empty?
      content_type :js
      JSON::pretty_generate users
    end


    # organization      ------------------------------------
    #
    get '/organization/attributes' do
      content_type :js
      JSON::pretty_generate OIM::do.org.list_attributes.sort
    end
  
    get '/organization' do
      if params.size > 0
        params['act_key'] = params['act_key'].to_i if params.key?('act_key')
        orgs = OIM::do.org.search_for(params)
      else  
        orgs = OIM::do.org.index
      end
      halt 404 if orgs.nil? or orgs.empty?
      content_type :js
      JSON.pretty_generate orgs
    end
  
    get '/organization/:id' do
      orgs = OIM::do.org.search_for( { 'act_key' => params[:id] } )
      halt 404 if orgs.nil? or orgs.empty?
      content_type :js
      JSON::pretty_generate orgs
    end
  
    post '/organization' do
      data = JSON.parse(request.body.read)
      org = OIM::do.org.create(data)
    end
  
    delete '/organization/:id' do
      halt 500 unless OIM::do.org.delete params[:id]
      204
    end
  
    run! if app_file == $0
  end
end

