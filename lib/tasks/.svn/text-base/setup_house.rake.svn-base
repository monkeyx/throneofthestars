desc "sets up a noble house"
task :setup_house => :environment do
  house = NobleHouse.find(ENV['HOUSE_ID'])
  house.do_signup!(ENV)
end
