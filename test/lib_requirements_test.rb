require_relative 'test_helpers.rb'

describe "### HELPERS MODULE ###" do
  before do
    class SampleClass < Object
      include Helpers
    end
    @sampleClass = SampleClass.new
  end

  
  it "Does non_zero_integer? work?" do
    assert(@sampleClass.non_zero_integer? 3)

    bad_args = ["", 0, {}, [], 6.66, Object.new]
    bad_args.each { |bad_arg| 
      refute(@sampleClass.non_zero_integer?(bad_arg))
    }
  end

  it "Does non-blank_string? work?" do
    assert(@sampleClass.non_blank_string? "xxx")
    
    bad_args = ["", 0, {}, [], 6.66, Object.new]
    bad_args.each { |bad_arg| 
      refute(@sampleClass.non_blank_string?(bad_arg))
    }
  end

  it "Does available_id? work?" do
    assert (@sampleClass.available_id?(4, [1,2,3]))

    refute (@sampleClass.available_id?(1, [1,2,3]))
    refute (@sampleClass.available_id?("X", [1,2,3]))
  end

  describe "Does valid_date_range? work?" do
    before do
      class SampleClass < Object
        include Helpers
      end
      @sampleClass = SampleClass.new

      @today = Date.new(2019,9,4)
      @yesterday = @today - 1
      @tomorrow = @today + 1
    end
    
    it "return T when expected" do
      assert(@sampleClass.valid_date_range?(@today, @tomorrow))
      assert(@sampleClass.valid_date_range?(@yesterday, @tomorrow))
    end 

    it "return F when expected" do
      refute(@sampleClass.valid_date_range?(@tomorrow, @yesterday))
      refute(@sampleClass.valid_date_range?(@today, @today))
      refute(@sampleClass.valid_date_range?("garbage", "trash"))
    end

  end

end