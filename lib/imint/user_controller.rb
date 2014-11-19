require_relative 'includer'

module Imint

  class UserController

    attr_accessor :client, :svc, :atts

    def initialize(client = nil)
      @client = client
      @svc    = client.getService(JUser::UserManager.java_class)
      @svcp   = client.getService(JUser::ProvisioningService.java_class)
      @svce   = client.getService(JUser::EntitlementService.java_class)
      @atts   = JHashSet.new()
      JUser::UserManagerConstants::AttributeName.values.each { |a| @atts.add a.getId }
    end

    def list_attributes
      @atts.to_set.to_a
    end

    def index
      search JClient::SearchCriteria.new('First Name', 
                                         'ZZZ', 
                                         JClient::SearchCriteria::Operator::NOT_EQUAL)
    end

    def search_for(para)
      clist = []
      para.map   { |k,v| clist << 
                   JClient::SearchCriteria.new(k, v, JClient::SearchCriteria::Operator::EQUAL) }
      search(clist.reduce { |m,o| 
        JClient::SearchCriteria.new(m, o, JClient::SearchCriteria::Operator::AND) })
    end

    #@svc.resetPassword(u.getLogin, true, false)
    def create(para)
      u = JUser::User.new(java.lang.String.new(SecureRandom.uuid), java.util.HashMap.new(para))
      @svc.create(u)
    end

    def delete(uid)
      @svc.delete(java.lang.String.new(uid), false)
    end

    def update(uid, para)
      @svc.modify(JUser::User.new(java.lang.String.new(uid), java.util.HashMap.new(para)))
    end
     
    def change_password(id, data)
      begin
        @svc.changePassword(id, data['password'].to_java.toCharArray, false, false)
      rescue Exception => ex
        ex
      end
    end

    def get_user_entitlements(params)
      begin
        ent_name = get_entitlement(params[:eid].to_i).getDisplayName
        scrit = JClient::SearchCriteria.new(
          JUser::ProvisioningConstants::EntitlementSearchAttribute::ENTITLEMENT_DISPLAYNAME.getId,
          ent_name,
          JClient::SearchCriteria::Operator::EQUAL)
        @svcp.getEntitlementsForUser(params[:id], scrit, JHashMap.new())
      rescue Exception => ex
        ex
      end
    end

    def revoke_user_entitlement(params)
      begin
        entitlements = get_user_entitlements(params)
        raise IOError if entitlements.empty?
        @svcp.revokeEntitlement(entitlements.get(0))
      rescue Exception => ex
        ex
      end
    end

    protected 
    def get_entitlement(id)
      begin
        @svce.findEntitlement(id)
      rescue Exception => ex
        ex
      end
    end

    protected
    def search(crit)
      @svc.search(crit, @atts, nil).map do |e|
        a = e.get_attributes.to_hash
        a.delete_if { |k,v| v.nil? }
      end
    end
  end
end

