class Order < ActiveRecord::Base
  attr_accessible :character, :character_id, :code, :special_instruction, :run_at, :signal, :finished, :success, :error_msg, :run_chronum, :order_parameters_attributes
  
  def self.load_descriptions(data_file)
    codes = {}
    File.open(data_file, 'r') do |file|
      while line = file.gets do
        code,text,help = line.split("||")
        codes[code] = []
        codes[code][0] = text
        codes[code][1] = help
      end
    end
    codes
  end

  DESCRIPTIONS = load_descriptions("#{File.dirname(__FILE__)}/../../config/order_descriptions.csv")

  NORMAL = "Normal"
  REPEAT = "Repeat"
  STOP = "Stop"
  STANDING = "Standing"
  WAITING = "Waiting"
  SIGNAL = "Signal"
  SPECIAL_INSTRUCTIONS = [NORMAL, REPEAT, STOP, STANDING, WAITING, SIGNAL]

  belongs_to :character

  scope :belongs_to, lambda {|character|
    {:conditions => {:character_id => character.id}}
  }

  validates_inclusion_of :code, :in => OrderProcessing::BaseOrderProcessor::CODES
  validates_inclusion_of :special_instruction, :in => SPECIAL_INSTRUCTIONS
  scope :waiting, :conditions => {:special_instruction => WAITING}
  
  # signal
  scope :signal, lambda {|signal|
    {:conditions => {:signal => signal}}
  }

  # finished

  scope :pending, :conditions => {:finished => false}, :include => [:character, :order_parameters], :order => 'id ASC'
  scope :ranked, lambda {|rank|
    {:conditions => {:rank => rank}}
  }

  scope :of, lambda {|character|
    {:conditions => {:character_id => character.id}}
  }

  game_date :run_at
  # success
  scope :successful, :conditions => {:success => true}
  scope :failed, :conditions => {:success => false}
  # error_msg
  # run_chronum
  scope :been_run, :conditions => {:run_chronum => true}
  scope :not_run, :conditions => {:run_chronum => false}

  has_many :order_parameters, :dependent => :destroy
  
  accepts_nested_attributes_for :order_parameters

  validate :validate_order

  scope :next_order_of, lambda {|character|
    {:conditions => ["character_id = ? AND finished = ? AND (special_instruction NOT IN (?) OR run_chronum = ?)", character.id, false, [STANDING, WAITING], false], :include => [:character, :order_parameters], :limit => 1, :order => 'id ASC'}
  }

  def self.clear_all_run_chronum!
    update_all("run_chronum = 0, error_msg = ''")
  end

  def self.pending_character_queues
    Timer.start_timer "Pending Character Queues"
    queues = []
    character = nil
    character_orders = nil
    skip_character = false
    pending.find_each do |order|
      if character.nil? || character.id != order.character_id
        character = order.character
        character_orders = []
        queues << character_orders
        skip_character = false
      end
      unless skip_character || order.waiting? || order.run_chronum?
        character_orders << order
      end
      if order.stop? || order.waiting?
        skip_character = true
      end
    end
    queues.sort_by{rand}
    Timer.puts_timer "Pending Character Queues"
    queues
  end

  def pending?
    !finished
  end

  def rank
    pending? ? Order.pending.of(self.character).index(self) : false
  end

  def next_order
    return nil unless rank
    list = Order.pending.of(self.character)
    return nil unless list.size > rank
    list[(rank+1)]
  end

  def previous_order
    return nil unless rank
    return nil if rank < 1
    list = Order.pending.of(self.character)
    list[(rank-1)]
  end

  def end_of_queue?
    next_order.nil?
  end

  def start_of_queue?
    previous_order.nil?
  end

  def swap!(order)
    return false unless rank && order.rank
    return false unless self.character_id == order.character_id
    transaction do
      new_code = order.code
      new_si = order.special_instruction
      new_run_t = order.run_at
      new_signal = order.signal
      new_finished = order.finished
      new_success = order.success
      new_error_msg = order.error_msg
      new_run_chronum = order.run_chronum
      new_order_parameters = order.order_parameters.map{|p| p}

      order.update_attributes!(:code => self.code, :special_instruction => self.special_instruction, :run_at => self.run_at,
        :signal => self.signal, :finished => self.finished, :success => self.success, :error_msg => self.error_msg,
        :run_chronum => self.run_chronum)
      self.order_parameters.each{|p| p.order_id = order.id; p.save! }

      self.update_attributes!(:code => new_code, :special_instruction => new_si, :run_at => new_run_t,
        :signal => new_signal, :finished => new_finished, :success => new_success, :error_msg => new_error_msg,
        :run_chronum => new_run_chronum)
      new_order_parameters.each{|p| p.order_id = self.id; p.save! }
    end
  end

  def move_up!
    return false if start_of_queue?
    swap!(previous_order)
  end

  def move_down!
    return false if end_of_queue?
    swap!(next_order)
  end

  def prepare(first_parameter=nil)
    order_processor.prepare_new_parameters
    unless self.order_parameters.empty? || first_parameter == nil
      self.order_parameters[0].parameter_value = first_parameter 
    end
  end

  def standing?
    self.special_instruction == STANDING
  end

  def stop?
    self.special_instruction == STOP
  end

  def waiting?
    self.special_instruction == WAITING
  end

  def valid_for_character?
    character && character.can_be_given_orders? && order_processor && order_processor.valid_for_character?
  end

  def processable?
    return false unless self.character.action_points && self.action_point_cost && self.character.action_points >= self.action_point_cost
    return false if waiting?
    return false if self.run_chronum? && (stop? || standing?)
    unless valid_for_character?
      destroy
      return false
    end
    check = order_processor.processable?
    unless check || !finished?
        news_msg = self.error_msg.blank? ? nil : "Error: #{self.error_msg}"
        self.character.add_news!("ORDER_FAILED", "#{self.to_s} #{news_msg}")
        character.use_action_points!(action_point_cost_on_fail)
        destroy
    end
    check
  end

  def process!
    self.error_msg = ''
    return continue? unless processable?
    transaction do
      Timer.start_timer("process!")
      begin
        if order_processor.process!
          succeeded!
        else
          failed!
        end
      rescue Exception => e
        failed!(e.to_s)
        Kernel.p e.backtrace
      rescue RuntimeError => e
        failed!(e.to_s)
        Kernel.p e.backtrace
      end
      handle_special_instruction!
      if success?
        character.use_action_points!(action_point_cost)
      else
        news_msg = self.error_msg.blank? ? nil : "Error: #{self.error_msg}"
        self.character.add_error!("ORDER_FAILED", "#{self.to_s} #{news_msg}")
        character.use_action_points!(action_point_cost_on_fail)
      end
      destroy if finished?
      Timer.puts_timer("process!")
    end
    continue?
  end

  def continue?
    standing? || success? || !stop?
  end

  def succeeded!
    @skip_validation = true
    update_attributes!(:success => true, :run_at => Game.current_date, :run_chronum => true, :finished => !(standing?), :error_msg => nil)
    self
  end

  def failed!(msg=nil)
    old_msg = self.error_msg
    msg_parts = []
    msg_parts << self.error_msg unless self.error_msg.blank?
    msg_parts << msg unless msg.nil?
    msg_parts = msg_parts.uniq
    msg = msg_parts.empty? ? nil : msg_parts.join(", ")
    # puts "Failed: #{msg}"
    @skip_validation = true
    update_attributes!(:success => false, :run_at => Game.current_date, :run_chronum => true, :finished => !(standing? || stop?), :error_msg => msg)
    self
  end

  def handle_special_instruction!
    case self.special_instruction
    when REPEAT
      copy.valid? && copy.save
    when SIGNAL
      Order.waiting.signal(self.signal).each do |order|
        order.update_attributes!(:special_instruction => NORMAL, :signal => nil)
      end
    end
  end

  def variable_points_cost?
    return true unless order_processor
    order_processor.variable_points_cost?
  end

  def action_point_cost
    return 0 unless order_processor
    order_processor.action_points
  end

  def action_point_cost_on_fail
    return 0 unless order_processor
    order_processor.action_points_on_fail
  end

  def validate_order
    unless defined?(@skip_validation) && @skip_validation
      self.errors.add("Order", "is not valid for this character (#{self.character.display_name})") unless order_processor.valid_for_character?
      self.errors.add("Signal","must be specified") if (self.special_instruction == WAITING || self.special_instruction == SIGNAL) && self.signal.blank?
    end
  end

  def copy
    o = Order.new(:character => self.character, :code => self.code, :special_instruction => self.special_instruction)
    self.order_parameters.each do |param|
      o.order_parameters.new(:label => param.label, :parameter_type => param.parameter_type, :parameter_value => param.parameter_value)
    end
    o
  end

  def order_processor
    return @processor if @processor
    @processor = OrderProcessing::BaseOrderProcessor.order_processor(self.code,self)
    return nil unless @processor
    @processor.calculate_action_points
    @processor
  end

  def to_s
    s = self.code
    s = s + " {" + self.order_parameters.to_a.map{|p| p.to_s }.join(", ") + "} " if self.order_parameters.size > 0
    s.html_safe
  end

  def css_class
    if self.error_msg.blank?
      'processable'
    else
      'unprocessable'
    end
  end
  
end

