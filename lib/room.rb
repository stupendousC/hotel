require_relative 'lib_requirements.rb'

class Room
  include Helpers
  attr_reader :id, :nightly_rate, :calendar_hash
  STANDARD_RATE = 200

  def initialize(id: , nightly_rate: STANDARD_RATE)
    
    # validate id
    unless non_zero_integer?(id)
      raise ArgumentError, "id #{id} must be a non-zero integer"
    end
    @id = id

    # validate nightly_rate (not gonna bother w/ float prices)
    if (nightly_rate != STANDARD_RATE) && !(non_zero_integer?(nightly_rate))
      raise ArgumentError, "nightly_rate #{nightly_rate} must be a non-zero integer"
    end
    @nightly_rate = nightly_rate

    @calendar_hash = {}
  end


  def check_avail(date:nil, date_range:nil)
    # TODO, must have ONE of the args
  end

  def make_unavail(date:nil, date_range:nil)
    # TODO, must have ONE of the args
  end

end