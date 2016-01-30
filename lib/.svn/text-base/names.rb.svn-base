module Names
  def self.load_names(data_file)
    list = []
    File.open(data_file, 'r') do |file|
      while line = file.gets do
        list << line.strip.titleize
      end
    end
    list
  end

  MALE_NAMES = load_names("#{File.dirname(__FILE__)}/../config/male_names.txt")
  FEMALE_NAMES = load_names("#{File.dirname(__FILE__)}/../config/female_names.txt")
  HOUSE_NAMES = (load_names("#{File.dirname(__FILE__)}/../config/house_names.txt")).uniq.sort_by{rand}

  def self.random_name(gender)
    list = gender == "Male" ? MALE_NAMES : FEMALE_NAMES
    list.sample
  end
end
