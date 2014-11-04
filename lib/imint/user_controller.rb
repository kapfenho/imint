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
      search JClient::SearchCriteria.new('First Name', 'ZZZ', JClient::SearchCriteria::Operator::NOT_EQUAL)
    end

    def search_for(para)
      clist = []
      para.map   { |k,v| clist << JClient::SearchCriteria.new(k, v, JClient::SearchCriteria::Operator::EQUAL) }
      search(clist.reduce { |m,o| JClient::SearchCriteria.new(m, o, JClient::SearchCriteria::Operator::AND) })
    end

    def create(para)
      h = java.util.HashMap.new(para)
      u = JUser::User.new(java.lang.String.new(SecureRandom.uuid), h)
      usr = @svc.create(u)
      @svc.resetPassword(u.getLogin, true, false)
      usr
    end

    def delete(uid)
      @svc.delete(java.lang.String.new(uid), false)
    end

    def update(uid, para)
      u = JUser::User.new(java.lang.String.new(uid), java.util.HashMap.new(para))
      @svc.modify(u)
    end
     
    # NoSuchUserException: If user with given userID does not exist
    # AccessDeniedException: If logged-in user does not have permission to change the password of this user
    # UserManagerException: If there is an error while changing the user's password.
    #                       Usually this means that the password policy violation was triggered 
    def change_password(id, data)
      begin
        @svc.changePassword(id, data['password'].to_java.toCharArray, false, false)
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

