require_relative 'lib_requirements.rb'

class Customer
  attr_reader :id, :name, :reservations, :all_customers, :available_id
  include Validation
  @@all_customers = {}
  @@available_id = 1
  
  def initialize(id: nil, name:, reservations: [])
    # Validate id
    if id && non_zero_integer?(id)
      if @@all_customers.keys.include? id
        raise ArgumentError, "id ##{id}has been taken"
      else
        @id = id
      end
    else
      @id = next_id
    end
    
    # Validate name
    if non_blank_string?(name)
      @name = name
    end
    puts "CONFIRMED!!! name = #{name}\t@name = #{@name}"
    
    # Validate reservations
    # if (reservations != [])
    #   if reservations.class != Array
    #     raise ArgumentError, "reservations must be an Array"
    #   else 
    #     # reservation.each do |element|
    #     #   if element.class != Reservation
    #     #     raise ArgumentError, "elements of reservations array must be Reservation objects"
    #     #   end
    #   end
    # end
    @reservations = reservations
    
    # update_all_customers
  end
  
  def next_id
    puts "using id##{@@available_id}"
    @@available_id += 1
  end

  def update_all_customers
    @@all_customers[@id] = self
    p all_customers
  end
  

  def to_s
    return "#{@name}, id##{id}, reservations = #{reservations}"
  end
  
  def self.all_customers
    @@all_customers
  end
  

end