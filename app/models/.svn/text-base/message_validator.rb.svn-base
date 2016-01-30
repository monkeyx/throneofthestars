class MessageValidator < ActiveModel::Validator
  def validate(record)
  	return unless record.new_record?
  	unless record.internal
    	record.errors[:character_id] << "No valid sender specified" unless record.character && record.character.noble_house && record.character.noble_house.player
    	record.errors[:from_id] << "No valid recipient specified" unless record.from && record.from.noble_house && record.from.noble_house.player
    end
    record.errors[:base] << "Insufficient funds" unless record.sovereigns.nil? || record.sovereigns <= record.from.noble_house.wealth
  end
end
