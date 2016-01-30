module GameUpdater
  def self.update_time!
    Timer.start_timer(:update_time)
    Log.info "UPDATE", "Time moves on"
    Game.current.next_chronum!
    Log.info "UPDATE", "It is #{Game.current_date.to_pretty_text} (Done in #{Timer.time_taken(Timer.timer_start_time(:update_time))})"
  end

  def self.clear_orders!
    Timer.start_timer(:clear_orders)
    Order.clear_all_run_chronum!
    Log.info "UPDATE", "Orders tried afresh (Done in #{Timer.time_taken(Timer.timer_start_time(:clear_orders))})"
  end

  def self.rotate_worlds!
    Timer.start_timer(:rotate_worlds)
    World.find_each do |world|
      world.rotate!
    end
    Log.info "UPDATE", "Worlds rotated (Done in #{Timer.time_taken(Timer.timer_start_time(:rotate_worlds))})"
  end

  def self.cleanup!
    Timer.start_timer(:cleanup)
    Region.cleanup_claimed_lands!
    Log.info "UPDATE", "Data cleaned up (Done in #{Timer.time_taken(Timer.timer_start_time(:cleanup))})"
  end

  def self.refuel_shuttles!
    Timer.start_timer(:refuel_shuttles)
    Building.reset_building_capacities!
    Log.info "UPDATE", "Shuttles are refuelled (Done in #{Timer.time_taken(Timer.timer_start_time(:refuel_shuttles))})"
  end

  def self.characters!
    Timer.start_timer(:characters)
    Skill.clear_student_ranks!
    Character.move_out_of_limbo!
    Character.find_each(:include => [:noble_house, :skills, :traits], :conditions => ["dead = ?", false]) do  |c|
      @char_holder = c
      if c.expired?
        #Timer.start_timer("Character #{c.id} expired")
        c.die!("natural causes")
        #Timer.puts_timer("Character #{c.id} expired")
      else
        #Timer.start_timer("Character #{c.id} health check")
        c.health_check!
        #Timer.puts_timer("Character #{c.id} health check")
      end
      if c.alive?
        #Timer.start_timer("Character #{c.id} check to move to home estate")
        c.move_to_home_estate! if c.location.nil? || (c.location_foreign? && c.infant_or_child?)
        #Timer.puts_timer("Character #{c.id} check to move to home estate")
        #Timer.start_timer("Character #{c.id} add action points")
        c.add_action_points!
        #Timer.puts_timer("Character #{c.id} add action points")
        if c.male?
          #Timer.start_timer("Character #{c.id} check for legitimate births")
          c.check_for_legitimate_birth!
          #Timer.puts_timer("Character #{c.id} check for legitimate births")
          #Timer.start_timer("Character #{c.id} check for illegitimate births")
          c.check_for_illegitimate_birth!
          #Timer.puts_timer("Character #{c.id} check for illegitimate births")
        end
        #Timer.start_timer("Character #{c.id} grow")
        c.grow!
        #Timer.puts_timer("Character #{c.id} grow")
        #Timer.start_timer("Character #{c.id} skill training")
        c.skill_training!
        #Timer.puts_timer("Character #{c.id} skill training")
        if c.steward?
          if c.location_estate? && c.location.steward_id == c.id
            #Timer.start_timer("Character #{c.id} automated resource gathering")
            c.location.automated_resource_gathering!
            #Timer.puts_timer("Character #{c.id} automated resource gathering")
            #Timer.start_timer("Character #{c.id} automated production")
            c.location.automated_production!
            #Timer.puts_timer("Character #{c.id} automated production")
          end
        elsif c.tribune?
          if c.location_estate? && c.location.tribune_id == c.id
            #Timer.start_timer("Character #{c.id} automated recruitment")
            c.location.automated_recruitment!
            #Timer.puts_timer("Character #{c.id} automated recruitment")
          end
        end
        #Timer.start_timer("Character #{c.id} check loyalty")
        c.check_loyalty!
        #Timer.puts_timer("Character #{c.id} check loyalty")
        #Timer.start_timer("Character #{c.id} birthday")
        c.do_birthday!
        #Timer.puts_timer("Character #{c.id} birthday")
      end
      print "."
      STDOUT.flush
    end
    puts ""
    Log.info "UPDATE", "Characters live (Done in #{Timer.time_taken(Timer.timer_start_time(:characters))})"
    @char_holder = nil
  end

  def self.noble_houses!
    Timer.start_timer(:noble_houses)
    NobleHouse.find_each do |house|
      house.automated_appointments!
      house.tidy_relations!
      print "."
      STDOUT.flush
    end
    NobleHouse.gm.update_attributes!(:glory => 0, :honour => 0, :piety => 0)
    Player.abandoned.each do |p|
      house = p.noble_house
      house.cease! if house && house.active?
    end
    puts ""
    Log.info "UPDATE", "Noble Houses (Done in #{Timer.time_taken(Timer.timer_start_time(:noble_houses))})"
  end

  def self.estates!
    Timer.start_timer(:estates)
    Estate.find_each do |estate|
      @estate_holder = estate
      estate.emancipation!
      estate.collect_rents!
      estate.automated_market_sales! if estate.noble_house && estate.noble_house.ancient?
      estate.pay_wages!
      print "."
      STDOUT.flush
    end
    puts ""
    @estate_holder = nil
    Log.info "UPDATE", "Estates are managed (Done in #{Timer.time_taken(Timer.timer_start_time(:estates))})"
  end

  def self.populations!
    Timer.start_timer(:populations)
    order = [Item::ARTISAN_WORKER, Item::FREEMEN_WORKER, Item::SLAVE_WORKER]
    order.each do |worker_type|
      World.find_each do |world|
        # Log.info "UPDATE", "#{worker_type} buys on #{world.name}"
        regions = world.regions.to_a.sort_by{rand}
        regions.each do |region|
          Population.region(region).category(worker_type).find_each do |pop|
            @pop_holder = pop
            pop.buy_needs!
            pop.pay_taxes! if Game.new_year?
            print "."
            STDOUT.flush
          end
        end
      end
    end
    puts ""
    @pop_holder = nil
    Log.info "UPDATE", "Populations buy and tax (Done in #{Timer.time_taken(Timer.timer_start_time(:populations))})"
  end

  def self.starships!
    Timer.start_timer(:starships)
    Scan.expire_old!
    Starship.clear_debris!
    Log.info "UPDATE", "Starship updates (Done in #{Timer.time_taken(Timer.timer_start_time(:starships))})"
  end

  def self.justice!
    Timer.start_timer(:justice)
    Accusation.resolutions!
    Log.info "UPDATE", "Justice (Done in #{Timer.time_taken(Timer.timer_start_time(:justice))})"
  end

  def self.truces!
    Timer.start_timer(:truces)
    DiplomaticRelation.remove_all_expired_truces!
    Log.info "UPDATE", "Expire truces (Done in #{Timer.time_taken(Timer.timer_start_time(:truces))})"
  end

  def self.weddings!
    Timer.start_timer(:weddings)
    Wedding.now.each do |wedding|
      wedding.happen!
    end
    Log.info "UPDATE", "Weddings (Done in #{Timer.time_taken(Timer.timer_start_time(:weddomgs))})"
  end

  def self.tournaments!
    Timer.start_timer(:tournaments)
    Tournament.now.each do |tournie|
      tournie.happen!
    end
    Log.info "UPDATE", "Tournaments (Done in #{Timer.time_taken(Timer.timer_start_time(:tournaments))})"
  end

  def self.armies!
    Timer.start_timer(:armies)
    @army_holder = nil
    Army.all.each do |army|
      @army_holder = army
      army.pay_wages!
      army.chronum_morale_adjustments!
      print "."
      STDOUT.flush
    end
    puts ""
    @army_holder = nil
    Log.info "UPDATE", "Armies wages and morale (Done in #{Timer.time_taken(Timer.timer_start_time(:armies))})"
  end

  def self.chapels!
    Timer.start_timer(:chapels)
    chapel = BuildingType.category(BuildingType::CHAPEL).first
    Building.building_type(chapel).each do |chapel|
      Title.elect_deacon!(chapel.estate)
    end
    Log.info "UPDATE", "Chapel deacons elected (Done in #{Timer.time_taken(Timer.timer_start_time(:chapels))})"
  end

  def self.church_elections!
    Timer.start_timer(:church_elections)
    Region.no_bishop.each{|region| Title.elect_bishop!(region)}
    World.no_archbishop.each{|world| Title.elect_archbishop!(world)}
    Title.elect_pontiff!
    Log.info "UPDATE", "Church elections (Done in #{Timer.time_taken(Timer.timer_start_time(:church_elections))})"
  end

  def self.church_funds!
    Timer.start_timer(:church_funds)
    Region.has_bishop.each{|region| region.distribute_church_funds!}
    Log.info "UPDATE", "Church funds (Done in #{Timer.time_taken(Timer.timer_start_time(:church_funds))})"
  end

  def self.prisoners!
    Prisoner.cleanup!
    Prisoner.all.each{|p| p.check_for_escape!} if Game.new_year?
  end

  def self.run_updater!
      failed_update = false
      Game.updating!
      begin
        Game.transaction do
          Timer.start_timer
          @char_holder = nil
          @pop_holder = nil
          @estate_holder = nil
          @army_holder = nil
          Log.info "UPDATE", "Starting"
          cleanup!
          update_time!
          clear_orders!
          rotate_worlds!
          refuel_shuttles!
          truces!
          characters!
          noble_houses!
          estates!
          populations!
          starships!
          weddings!
          tournaments!
          armies!
          chapels!
          justice!
          prisoners!
          if Game.new_year?
            church_elections!
            church_funds!
          end
          Log.info "UPDATE", "Finished in #{Timer.time_taken}"
        end
      rescue Exception => e
        on_msg = "on Character #{@char_holder.id}" if @char_holder
        on_msg = "on Population #{@pop_holder.id}" if @pop_holder
        on_msg = "on Estate #{@estate_holder.id}" if @estate_holder
        on_msg = "on Army #{@army_holder.id}" if @army_holder
        Log.info "UPDATE", "Aborted #{on_msg} because #{e.message}\n#{e.backtrace.join("\n")}"
        failed_update = true
        exit
      rescue
        Log.info "UPDATE", "Aborted"
        failed_update = true
        exit
      ensure
        Game.game_unlock!  
        unless failed_update
          Timer.start_timer("player_emails")
          Player.deliver_house_news!
          Log.info("UPDATE", "Sent Player Emails :: Time taken #{Timer.time_taken(Timer.timer_start_time("player_emails"))}")
        end
      end # begin
  end
end
