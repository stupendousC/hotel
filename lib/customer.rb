require_relative 'lib_requirements.rb'

class Customer
  attr_reader :id, :name, :reservations
  include Validation
  
  class << self
    attr_reader :all_customers, :available_id
    @@all_customers = {}
    @@available_id = 1

    # I thought attr_reader automatically makes the following getter methods unnecessary...?
    def all_customers
      return @@all_customers
    end

    def available_id
      return @@available_id
    end
  end
  
  def initialize(id: nil, name:, reservations: [])
    # Validate id
    if id && non_zero_integer?(id)
      if @@all_customers.keys.include? id
        raise ArgumentError, "id ##{id}has been taken"
      else
        @id = id
      end
    else
      @id = @@available_id
    end
    
    # Validate name
    non_blank_string?(name)
    @name = name
    
    # Validate reservations
    if (reservations != [])
      if reservations.class != Array
        raise ArgumentError, "reservations must be an Array"
        # TODO elsewhere? HOW TO CHECK AGAINST NON-Reservation objs in arg???? 
        # would be best if done in front_desk?
      end
    end
    @reservations = reservations

    # update affected attribs
    scroll_to_next_id
    update_all_customers
  end
  
  def scroll_to_next_id
    @@available_id += 1
  end
  
  def update_all_customers
    @@all_customers[@id] = self
  end
  
  def to_s
    return "Customer obj: name = #{@name}, id = #{id}, reservations = #{reservations}"
  end
end