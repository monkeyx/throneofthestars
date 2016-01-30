class AdminController < ApplicationController
  before_filter :store_location
  before_filter :require_gm

  def index
  end

  def players
  	unless params[:mod].blank?
  		@player = Player.find(params[:id])
  		@player.send(params[:mod])	
  		if @player.active?
  			flash[:notice] = "#{@player.name} <#{@player.email}> has been unlocked"
  		else
  			flash[:notice] = "#{@player.name} <#{@player.email}> has been locked"
  		end
  	end
  	unless params[:unconfirmed]
  		@players = Player.confirmed
  	else
  		@players = Player.unconfirmed
  	end
  end

  def spawner
  	unless params[:mod].blank?
  		@noble_house = NobleHouse.find(params[:noble_house])
  		case params[:mod]
  		when 'civil_servant'
  			@character = Spawner.civil_servant(@noble_house)
  		when 'acolyte'
  			@character = Spawner.acolyte(@noble_house)
  		when 'captain'
  			@character = Spawner.captain(@noble_house)
  		when 'legate'
  			@character = Spawner.legate(@noble_house)
  		when 'prize_ship'
  			estate_name = params[:estate_name].blank? ? nil : params[:estate_name]
  			artefact_name = params[:artefact_name].blank? ? nil : params[:artefact_name]
  			@ship = Spawner.prize_ship(@noble_house,params[:configuration], params[:news_code],estate_name,artefact_name)
  		when 'seed_artefacts'
  			Spawner.seed_artefacts
  			flash[:notice] = 'Artefacts seeded'
  		end
  		if @character
  			flash[:notice] = "#{@character.display_name} added to House #{@noble_house.name}"
  		end
  		if @ship
  			flash[:notice] = "SS #{@ship.name} added to House #{@noble_house.name}"
  		end
  	end
  end

  def reported
  	@messages = Message.reported
  end

  def newsletter
    unless params[:mod].blank?
      if params[:mod] == 'test'
        Player.gm.deliver_newsletter!(params[:content])
        flash[:notice] = "Sent test newsletter to GM"
      elsif params[:mod] == 'send'
        Game.current.save_newsletter(params[:content])
        call_rake(:send_newsletter)
        flash[:notice] = "Started sending newsletter to all confirmed players"
      end
    end
  end
end
