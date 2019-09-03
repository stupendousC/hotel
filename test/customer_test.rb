require_relative 'test_helper.rb'

describe "### CUSTOMER CLASS ###" do
  describe "Customer.initialize" do 
    
    let (:pam) { Customer.new(name: "Pam Poovey") }
    let (:cheryl) { Customer.new(name: "Cheryl Tunt", id: 1) }

    it "Can create a Customer class object" do
      expect(pam).must_be_kind_of Customer
    end


    it ".initialize will reject bad args" do
      expect {Customer.new()}.must_raise ArgumentError

      bad_names = ["", 666, {}, [], 6.66, Object.new]
      bad_names.each { |bad_arg| expect {Customer.new(name: bad_arg)}.must_raise ArgumentError }
      
    
      bad_ids = ["", {}, [], 6.66, Object.new]
      bad_ids.each { |bad_arg| expect {Customer.new(id: bad_arg, name: "OK")}.must_raise ArgumentError }
      
      bad_reservations = ["", 666, {}, 6.66, Object.new]
      bad_reservations.each { |bad_arg| expect {Customer.new(reservations: bad_arg, name: "OK")}.must_raise ArgumentError }

    end

    it "Can read attributes" do
      expect(pam.name).must_equal "Pam Poovey", "name doesn't match @name"
      expect(pam.reservations).must_equal [], "should've initialized w/ []"
      # expect(pam.id).must_equal Customer.availabld_id - 1
      
    end
  end




end

##### IF USING PRY ##### pry -r ./test/customer_test.rb


pam = Customer.new(name: "Pam Poovey") 
cheryl = Customer.new(name: "Cheryl Tunt", id: 1) 
binding.pry
########################