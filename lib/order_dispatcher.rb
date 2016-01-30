module OrderDispatcher
  def self.run_dispatcher!
    unless Game.game_locked?
      Game.transaction do
        Timer.start_timer
        successful = 0
        total = 0
        characters = 0
        errors = 0
        all_queues = Order.pending_character_queues
        Log.info "DISPATCH", "Starting :: #{all_queues.size} order queues"
        Game.dispatching!
        all_queues.each do |queue|
          characters += 1
          i = 0
          while i < queue.size do
            begin
              Timer.start_timer("order_#{i}")
              order = queue[i]
              total += 1
              unless order.process!
                i = queue.size
              else
                successful += 1
              end
              print "."
              STDOUT.flush
            rescue Exception => e
              errors += 1
              if order
                Log.info "DISPATCH", "Error processing order #{order.id} for character #{order.character.id} :: #{e.to_s}\n#{e.backtrace.join("\n")}"
              end
            rescue RuntimeError => e
              errors += 1
              if order
                Log.info "DISPATCH", "Error processing order #{order.id} for character #{order.character.id} :: #{e.to_s}\n#{e.backtrace.join("\n")}"
              else
                Log.info "DISPATCH", "#{e.to_s}\n#{e.backtrace.join("\n")}"
              end
            ensure
              Log.info "DISPATCH", "Order: #{order.code} for Character #{order.character.id} took #{Timer.time_taken(Timer.timer_start_time("order_#{i}"))}"
              i += 1
            end
          end
        end
        puts ""
        Game.game_unlock!
        Log.info "DISPATCH", "Finished :: Time: #{Timer.time_taken}\nCharacters: #{characters} Total Orders: #{total} Successful: #{successful} Errors: #{errors}."
      end
    else
      Log.info "DISPATCH", "Update in progress - quitting"
    end
  end
end
