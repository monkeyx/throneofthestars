namespace :thronestars do
  desc "locks the game down"
  task :lock => :environment do
    Game.game_lock!
  end

  desc "unlocks the game"
  task :unlock => :environment do
    Game.game_unlock!
  end

  desc "runs the order dispatcher"
  task :dispatcher => :environment do
    OrderDispatcher.run_dispatcher!
  end

  desc "runs the chronum update"
  task :updater => :environment do
    while Game.game_locked? do
      Log.info "UPDATE", "Waiting for dispatcher to finish"
      sleep(300)
    end
    GameUpdater.run_updater!
  end # task

  desc "runs the updater a number of times based on the YEARS parameter"
  task :sim => :environment do
    n = (ENV['YEARS'] && ENV['YEARS'].to_i) || 1
    (n * 10).times do
      GameUpdater.run_updater!
      OrderDispatcher.run_dispatcher!
    end
  end # task

  desc "clears the cache"
  task :clear_cache => :environment do
    Rails.cache.clear
  end

  task :capture_estate_sim => :environment do
    Spawner.capture_estate
  end

  task :ground_battle_sim => :environment do
    Spawner.ground_battle
  end

  task :space_battle_sim => :environment do
    Spawner.space_battle('Imperial Cruiser')
  end

  task :seed_artefacts => :environment do
    Spawner.seed_artefacts
  end

  task :population_buys => :environment do
    Game.transaction do
      GameUpdater.update_time!
      GameUpdater.estates!
      GameUpdater.populations!
    end
  end

  task :tournaments => :environment do
    Game.transaction do
      GameUpdater.update_time!
      GameUpdater.tournaments!
    end
  end

  task :character_update => :environment do
    Game.transaction do
      GameUpdater.update_time!
      GameUpdater.characters!
    end
  end

  task :region_cleanup => :environment do
    Game.transaction do
      Region.cleanup_claimed_lands!
    end
  end
end