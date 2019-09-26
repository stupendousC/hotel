require_relative 'lib_requirements.rb'
require_relative 'dateRange.rb'
require_relative 'csvRecord.rb'

class Reservation < CsvRecord
  include Helpers
  attr_reader :id, :cost, :customer, :room_id, :date_range, :start_date, :end_date, :new_nightly_rate, :block_id
  attr_accessor :block, :room
  
  # WHEN LOADING FROM CSV... hotelFrontDesk.new will invoke Reservation.load_all, which calls Reservation.from_csv, then calls Reservation.new()
  def self.load_all(full_path: nil, directory: nil, file_name: nil)
    super
  end
  
  def self.from_csv(record)
    # This will be called from hotelFrontDesk.rb, to pull info via .load_all()
    start_date = Date.parse(record[:start_date])
    end_date = Date.parse(record[:end_date])
    range = DateRange.new(start_date_obj:start_date, end_date_obj:end_date)
    
    record[:new_nightly_rate] ? (new_nightly_rate = record[:new_nightly_rate].to_f):(new_nightly_rate = STANDARD_RATE.to_f)
    record[:block_id] ? (block_id = record[:block_id].to_i):(block_id = nil)
    
    return new(
      id:record[:id].to_i,
      room_id:record[:room_id].to_i, 
      room: nil,  # can't store objs in csv, will link later
      cost: record[:cost].to_f,
      customer: record[:customer], 
      date_range: range, 
      new_nightly_rate: new_nightly_rate,
      block_id: block_id,
      block: nil  # can't store objs in csv, will link later
    )
  end
  
  def initialize(id: nil, room_id:, room:nil, date_range:, customer:, new_nightly_rate: nil, block: nil, block_id: nil, cost: nil)
    # If making a new instance via hotelFrontDesk: all arg validations done by precursor method HotelFrontDesk#make_reservation
    # If downloading from CSV, then assuming that they've already been vetted
    
    # id pre-exists if coming from CSV, else make new one up
    id ? (@id= id):(@id = Reservation.generate_id)
    
    @room_id = room_id
    @room = room  # nil if coming from CSV
    
    @block_id = block_id   
    @block = block  # nil if coming from CSV
    
    @date_range = date_range
    @start_date = @date_range.start_date
    @end_date = @date_range.end_date
    
    @customer = customer 
    @new_nightly_rate = new_nightly_rate
    
    # cost pre-exists if coming from CSV, else use calc_cost
    cost ? (@cost = cost):(calc_cost)
  end
  
  def calc_cost
    # Sets rate = 200/standard, unless overriding new_nightly_cost (higher/lower ok) exists
    rate = nil
    if @new_nightly_rate
      rate = @new_nightly_rate
    else
      rate = STANDARD_RATE
    end
    
    total_nights = (@end_date - @start_date).to_i   
    # I had to add .to_i b/c it returns a Rational of number/1, and i only want the number
    
    @cost = rate * total_nights
    
    return @cost
  end
  
  def to_s 
    string = "Reservation ##{id} for #{customer}: Room##{room_id}, #{start_date} until #{end_date}.  Total = $#{cost}."
    if @block
      string << " *#{block}*"
    end
    return string
  end
  
  
  class << self
    @@available_id = 1000
    
    def generate_id
      @@available_id += 1
      return @@available_id
    end
  end
  
end
