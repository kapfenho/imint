require_relative 'includer'

module Imint

  class UserController

    attr_accessor :client, :svc, :atts

    def initialize(client = nil)
      @client = client
      @svc    = client.getService(JUser::UserManager.java_class)
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

    def create(para)
      u = JUser::User.new(java.lang.String.new(SecureRandom.uuid), java.util.HashMap.new(para))
      @svc.create(u)
    # @svc.resetPassword(u.getLogin, true, false)
    end

    def delete(uid)
      @svc.delete(java.lang.String.new(uid), false)
    end

    def update(uid, para)
      @svc.modify(JUser::User.new(java.lang.String.new(uid), java.util.HashMap.new(para)))
    end
     
    # change password by uid or by login, like:
    # { uid: '1234',   password: 'newpwd' }
    # { login: '1234', password: 'newpwd' }
    #
    def change_password(data)
      begin
        if data[:uid]
          @svc.changePassword(data[:uid], data[:password].to_java.toCharArray, false,
                              false)
        else
          @svc.changePassword(data[:login], data[:password].to_java.toCharArray, true,
                              false)
        end
      rescue Exception => ex
        ex
      end
    end

    protected
    def search(crit)
      begin
        @svc.search(crit, @atts, nil).map do |e|
          a = e.get_attributes.to_hash
          a.delete_if { |k,v| v.nil? }
        end
      rescue Exception => ex
        ex
      end
    end
  end
end

