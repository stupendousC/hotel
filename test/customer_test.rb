require_relative 'test_helper.rb'

describe "### CUSTOMER CLASS ###" do
  describe "Customer.initialize" do 

    let (:mallory) { Customer.new(name: "Mallory Archer") }
    let (:pam) { Customer.new(name: "Pam Poovey") }
    let (:cheryl) { Customer.new(name: "Cheryl Tunt") } 
    let (:sterling) { Customer.new(name: "Sterling Archer" )}
    let (:krieger) { Customer.new(name: "Dr. Krieger" )}

    it "Can create a Customer class object" do
      expect(mallory).must_be_kind_of Customer
    end

    it "Will add new Customer object to @@all_customers" do
      sterling
      assert(Customer.all_customers.keys.include? sterling.id)
    end

    it "Will scroll up the @@available_id by 1 after initiation successful" do
      krieger
      assert(krieger.id + 1 == Customer.available_id)
    end

    it "Won't make new Customer if id arg is already taken" do
      cheryl
      expect {Customer.new(name:"Jerk Face", id:1)}.must_raise ArgumentError
    end

    it "Will raise error if bad args" do
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
      expect(pam.id).must_equal (Customer.available_id - 1)
    end

    it "COVERAGE CORRECT?" do
      assert(false, msg = "HELL NO!  WHY?????!!!")
    end
  end
end



##### IF USING PRY ##### pry -r ./test/customer_test.rb

# pam = Customer.new(name: "Pam Poovey") 
# cheryl = Customer.new(name: "Cheryl Tunt", id: 1) 
# binding.pry
########################