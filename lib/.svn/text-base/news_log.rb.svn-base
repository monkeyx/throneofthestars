module NewsLog
  def self.load_descriptions(data_file)
    codes = {}
    File.open(data_file, 'r') do |file|
      while line = file.gets do
        code,text = line.split("||")
        codes[code] = text
      end
    end
    codes
  end

  DESCRIPTIONS = load_descriptions("#{File.dirname(__FILE__)}/../config/news_codes.csv")

  def add_news!(code, target=nil, empire=false, church=false, news_date=Game.current_date, error_message=false)
    house = if self.class.name == 'NobleHouse'
      self
    else
      self.noble_house
    end
    News.add_news!(house,self,code,target,empire,church,news_date,error_message)
  end

  def add_error!(code, error_message)
    add_news!(code, error_message, false, false, Game.current_date, true)
  end

  def add_empire_news!(code,target=nil,news_date=Game.current_date)
    add_news!(code,target,true,false,news_date)
  end

  def add_church_news!(code,target=nil,news_date=Game.current_date)
    add_news!(code,target,false,true,news_date)
  end

  def news_log(current_house=nil)
    if self.is_a?(NobleHouse)
      if current_house && self.id == current_house.id
        News.of_house(self)
      else
        News.of_house(self).public
      end
    elsif current_house && current_house.id == self.noble_house.id
      News.about(self)
    else
      News.about(self).public
    end
  end

end
