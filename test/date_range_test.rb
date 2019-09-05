require_relative 'test_helpers.rb'

describe "### DATE_RANGE CLASS ###" do

  describe "Does Date_range.new() work?" do
    let (:today) { Date.new(2019,9,6 ) }
    let (:tomorrow) { today + 1 }
    let (:date_range1) { Date_range.new( start_date_obj: today, end_date_obj: today + 4) }

    it "Can make Date_range object" do
      expect(date_range1).must_be_kind_of Date_range
    end

    it "Raises error with bad args" do
      # bad DataType
      expect{Date_range.new(666, today)}.must_raise ArgumentError
      expect{Date_range.new(today, 666)}.must_raise ArgumentError
      expect{Date_range.new(Object.new, Array.new)}.must_raise ArgumentError
      # bad logic
      expect{Date_range.new(tomorrow, today)}.must_raise ArgumentError
    end

    it "Can access attributes" do
    end
  end

  describe "Does assemble_all_dates work?" do
    # included in Date_range.new(), impacts @all_dates & @all_nights 
  end

  describe "Does date_in_range? work?" do
  end

  describe "Does ranges_overlap? work?" do
  end


end