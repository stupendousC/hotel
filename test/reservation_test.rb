require_relative 'test_helpers.rb'

describe "### RESERVATION CLASS ###" do

  describe "Does Reservation.new() work?" do
    it "Can make Reservation object" do
    end

    it "Raises error with bad args" do
    end
  end

  it "Does Reservation.generate_id work?" do
    new_id = Reservation.generate_id
    assert(new_id == 1001)
  end

  describe "Does .gen_id() work?" do
  end

  describe "Does .calc_cost() work?" do
    it "Calculates cost correctly" do
    end

    it "Raises error with bad args" do
    end

  end


end