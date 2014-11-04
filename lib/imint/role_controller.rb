require_relative 'includer'

# Access to OIM for roles
# oim throws errors if you as for all attributes, therefore we need to specify them
#
module Imint

  class RoleController
  
    attr_accessor :client, :svc, :atts
  
    ATTS = [
      'LDAP DN',
      'LDAP GUID',
      'Role Category Key',
      'Role Description',
      'Role Display Name',
      'Role Email',
      'Role Key',
      'Role Name',
      'Role Namespace',
      'Role Owner Key',
      'Role Unique Name',
      'User Membership Rule',
      'ugp_create',
      'ugp_data_level',
      'ugp_update',
      'ugp_updateby'
   ]
    ATTS_NOT_USED = [
      'MT Role Name',
      'Tenant Name',
      'Tenant GUID'
    ]
 
    def initialize(client = nil)
      @client = client
      @svc    = client.getService(JRole::RoleManager.java_class)
      @atts   = JHashSet.new()
      ATTS.each { |a| @atts.add a}
    end
  
    def list_attributes
      @atts.to_set.to_a
    end

    def index
      search JClient::SearchCriteria.new('Role Name', 'ZZZ', JClient::SearchCriteria::Operator::NOT_EQUAL)
    end

    def search_for(para)
      clist = []
      para.map   { |k,v| clist << JClient::SearchCriteria.new(k, v, JClient::SearchCriteria::Operator::EQUAL) }
      search(clist.reduce { |m,o| JClient::SearchCriteria.new(m, o, JClient::SearchCriteria::Operator::AND) })
    end

    def get_members(params)
      crit = JClient::SearchCriteria.new('User Login', 'ZZZ', JClient::SearchCriteria::Operator::NOT_EQUAL)
      configParams = JHashMap.new( { "STARTROW" => 0, "ENDROW" => -1 } )
      attrs = JHashSet.new( [ "User Login" ] )
      @svc.getRoleMembers(params[:id], crit, attrs, configParams, true).map do |e|
        a = e.get_attributes.to_hash
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

