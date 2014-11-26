require_relative 'includer'

module Imint

  class ProvisioningController

    attr_accessor :client, :svc, :atts

    def initialize(client = nil)
      @client = client
      @svcp   = client.getService(JProv::ProvisioningService.java_class)
      @svce   = client.getService(JProv::EntitlementService.java_class)
    end

    # extract Entitlement attributes from EntitlementInstance object
    def parse_entitlements(ents)
        entitlements = Array.new
        ents.each do |en|
          e = 
            {:ent_list_key =>     en.getEntitlement.getEntitlementKey, 
             :ent_display_name => en.getEntitlement.getDisplayName,
             :ent_description =>  en.getEntitlement.getDisplayName,
             :ent_value =>        en.getEntitlement.getEntitlementValue,
             :svr_key =>          en.getEntitlement.getItResourceKey
            }
          entitlements.push(e)
        end
        entitlements
    end

    # the only way we can filter the entitlement search is via ENTITLEMENT_DISPLAYNAME.getId
    # that is why we have to fetch the entitlement name
    def get_user_entitlements(params)
      begin
        if params.key?('eid')
          ent_name = get_entitlement(params['eid'].to_i).getDisplayName
          scrit = JClient::SearchCriteria.new(
            JProv::ProvisioningConstants::EntitlementSearchAttribute::ENTITLEMENT_DISPLAYNAME.getId,
            ent_name, JClient::SearchCriteria::Operator::EQUAL)
          @svcp.getEntitlementsForUser(params['id'], scrit, JHashMap.new())
        else
          entitlements = @svcp.getEntitlementsForUser(params[:id])
          parse_entitlements(entitlements)
        end
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
  end
end

