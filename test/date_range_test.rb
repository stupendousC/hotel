require_relative 'test_helpers.rb'

describe "### DATE_RANGE CLASS ###" do

  describe "Does Date_range.new() work?" do
    let (:today) { Date.today}
    let (:tomorrow) { today + 1 }
    let (:range1) { Date_range.new( start_date_obj: today, end_date_obj: today + 3) }

    it "Can make Date_range object" do
      expect(range1).must_be_kind_of Date_range
    end

    it "Raises error with bad args" do
      # bad DataType
      expect{Date_range.new(666, today)}.must_raise ArgumentError
      expect{Date_range.new(today, 666)}.must_raise ArgumentError
      expect{Date_range.new(Object.new, Array.new)}.must_raise ArgumentError
      # bad logic
      expect{Date_range.new(tomorrow, today)}.must_raise ArgumentError

    end

    it "Can access attributes correctly" do
      assert(range1.start_date == today)
      assert(range1.end_date == today + 3)
    end
  end

  describe "Does date_in_range? work?" do
    let (:today) { Date.today}
    let (:checkout) { today + 3 }
    let (:range1) { Date_range.new( start_date_obj: today, end_date_obj: checkout ) }
    
    it "Returns True when expected" do
      good_args = [today, today+1, today+2, checkout]
      good_args.each do |good_arg|
        assert(range1.date_in_range?(good_arg))
      end
    end

    it "Returns False when expected" do
      refute(range1.date_in_range?(checkout+1))
      refute(range1.date_in_range?(today-1))
    end

    it "Raise error if bad args" do
      bad_args = [1, 0, -1, 1.2, "garbage", Object.new]
      bad_args.each do |bad_arg|
        expect{range1.date_in_range?(bad_arg)}.must_raise ArgumentError
      end
    end
  end

  describe "Does ranges_overlap? work?" do
    let (:today) { Date.today}
    let (:range1) { Date_range.new( start_date_obj: today, end_date_obj: today + 3) }

    it "Returns True when expected" do
      overlap1 = Date_range.new( start_date_obj: today-100, end_date_obj:today + 1)
      overlap2 = Date_range.new( start_date_obj: today+1, end_date_obj:today + 100)

      assert(range1.ranges_overlap?(overlap1))
      assert(range1.ranges_overlap?(overlap2))
      assert(range1.ranges_overlap?(range1))
    end

    it "Returns False when expected" do
      safe1 = Date_range.new( start_date_obj: today + 3, end_date_obj:today + 101)
      safe2 = Date_range.new( start_date_obj: today - 100, end_date_obj: today)
      safe3 = Date_range.new( start_date_obj: today + 100, end_date_obj:today + 101)

      refute(range1.ranges_overlap?(safe1))
      refute(range1.ranges_overlap?(safe2))
      refute(range1.ranges_overlap?(safe3))
    end

    it "Raise error if bad args" do
      bad_args = [1, 0, -1, 1.2, "garbage", Object.new]
      bad_args.each do |bad_arg|
        expect{range1.ranges_overlap?(bad_arg)}.must_raise ArgumentError
      end
    end
  end


end