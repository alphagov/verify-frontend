require 'set'

class IdpChecker
  def initialize
    @idps = {}
  end

  def add_rule(idp, docs)
    @idps[idp] ||= []
    @idps[idp].push(Set.new docs)
  end

  def idps_at_document_stage(user_has)
    user_docs = Set.new user_has
    @idps.select do |_,val|
      val.any? {|docs| (docs & docs_only).subset? user_docs}
    end.keys
  end

  def idps_at_phone_stage(user_has)
    user_docs = Set.new user_has
    @idps.select do |_,val|
      val.any? {|docs| docs.subset?(user_docs)}
    end.keys
  end

private

  def docs_only
    Set.new [:passport, :licence, :foreign_id]
  end

end
