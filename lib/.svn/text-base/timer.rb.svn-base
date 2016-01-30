module Timer
  TIMERS = {}
  
  def self.start_timer(timer_label=:all)
    timer_start_time(timer_label)
  end

  def self.timer_start_time(timer_label=:all)
    TIMERS[timer_label] ||= Time.zone.now
  end

  def self.time_taken(start_time=timer_start_time, finish_time=Time.zone.now)
    diff = finish_time - start_time
    return "#{diff.round(1)} seconds" if diff < 1
    minutes = (diff / 60).to_i
    seconds = (diff % 60).round(1)
    hours = (minutes / 60).to_i
    minutes = (minutes % 60).to_i
    parts = []
    parts << "#{hours} " + "hour".pluralize_if(hours) if hours > 0
    parts << "#{minutes} " + "minute".pluralize_if(minutes) if minutes > 0
    parts << "#{seconds} " + "second".pluralize_if(seconds) if seconds > 0

    parts.join(", ")
  end

  def self.puts_timer(timer_label=:all)
    start_time = timer_start_time(timer_label)
    timed = time_taken(start_time)
    puts "Timer: #{timer_label} done in #{timed}"
  end
end
