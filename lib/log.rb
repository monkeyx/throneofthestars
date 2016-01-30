module Log
  def self.info(task_name, msg)
    # TODO revise logging
    puts "STARTHRONE :: #{task_name} :: #{Time.zone.now} :: #{msg}"
  end
end
