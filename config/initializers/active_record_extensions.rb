module ActiveRecordExtensions
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def game_date(field)
      composed_of field, :class_name => 'GameDate', :mapping => %W(#{field} to_s), :converter => Proc.new{|gd| gd.to_s}, :constructor => Proc.new{|s| GameDate.read(s)}, :allow_nil => false
    end
    def dice(field)
      composed_of field, :class_name => 'Dice', :mapping => %W(#{field} to_s), :converter => Proc.new{|gd| gd.to_s}, :constructor => Proc.new{|s| Dice.read(s)}, :allow_nil => false
    end
    def chance(field)
      composed_of field, :class_name => 'Chance', :mapping => %W(#{field} to_s), :converter => Proc.new{|gd| gd.to_s}, :constructor => Proc.new{|s| Chance.read(s)}, :allow_nil => false
    end
  end
end

class ActiveRecord::Base
  include ActiveRecordExtensions
  def generate_guid
    self.guid ||= $UID.generate
  end
end