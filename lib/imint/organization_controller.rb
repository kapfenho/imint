require_relative 'includer'

module Imint

  # Access to OIM for organization
  # oim throws error during search when you request all attributes in result.
  # therefore we need to specify the result attributes -> 
  #    don't ask for the ATTS_NOT_USED
  #
  # Attention: customized attributes (UDF) are specified here.
  # unless commented the app will only run on customized 
  # backends

  class OrganizationController
  
    ATTS = [
      'Certifier User Key',
      'Certifier User Login',
      'Organization Customer Type',
      'Organization Name',
      'Organization Status',
      'Parent Organization Name',
      'Password Policy Name',
      'Password Policy',
      'act_key',
      'parent_key',
      'dwpAdministrationProce',
      'dwpApprovalMailNotific'
    ]
    ATTS_NOT_USED = [
      "Available Roles Rule",
      "User Membership Rule"
    ]
    
    attr_accessor :client, :svc, :atts
  
    def initialize(client = nil)
      @client = client
      @svc    = client.getService(JOrg::OrganizationManager.java_class)
      @atts   = JHashSet.new()
      # JOrg::OrganizationManagerConstants::AttributeName.values.each { |a| @atts.add a.getId }
      ATTS.each { |a| @atts.add a }
    end
  
    def list_attributes
      @atts.to_set.to_a
    end
  
    def index
      search JClient::SearchCriteria.new(JOrg::OrganizationManagerConstants::AttributeName::ORG_NAME.getId,
                                         'ZZZ', 
                                         JClient::SearchCriteria::Operator::NOT_EQUAL)
    end
  
    def search_for(para)
      clist = []
      para.map   { |k,v| clist << JClient::SearchCriteria.new(k, v, JClient::SearchCriteria::Operator::EQUAL) }
      search(clist.reduce { |m,o| JClient::SearchCriteria.new(m, o, JClient::SearchCriteria::Operator::AND) })
    end
  
    def create(para)
      h = java.util.HashMap.new(para)
      u = JOrg::Organization.new(java.lang.String.new(SecureRandom.uuid), h)
      @svc.create(u)
    end
  
    def delete(uid)
      @svc.delete(java.lang.String.new(uid), false)
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

