desc "sends the newsletter"
task :send_newsletter => :environment do
	Player.deliver_newsletter!(Game.current.load_newsletter)
end
