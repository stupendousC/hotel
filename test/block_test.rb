require_relative 'test_helpers.rb'

describe "### BLOCK CLASS ###" do
  
  describe "Block.new" do 
    # Validation is handled by precursor method Hotel_front_desk#make_block,
    # and will only run Block.new() if all args are legit
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }
    let (:room3) { Room.new(id:3) }

    it "Makes new Block instance with correct attributes" do
      block = Block.new(date_range:range1, new_nightly_rate:10, room_ids:[3], rooms:[room3])
      assert(block.class == Block)
      assert(block.new_nightly_rate == 10)
      assert(block.occupied_rooms == [])
      assert(block.occupied_room_ids == [])
      assert(block.unoccupied_rooms == [room3])
      assert(block.unoccupied_room_ids == [3])
      assert(block.all_reservations == [])

      expected_id = Block.class_variable_get(:@@available_id)
      assert(block.id == expected_id)
    end

    it "Raises error with bad args" do
      # Validation is handled by precursor method Hotel_front_desk#make_block,
      # and will only run Block.new() if all args are legit
      assert(true)
    end
    
  end

end