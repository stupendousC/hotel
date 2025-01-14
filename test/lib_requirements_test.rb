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
  
  it "Does non_zero_dollar_float? work?" do
    assert(@sampleClass.non_zero_dollar_float? 3)
    assert(@sampleClass.non_zero_dollar_float? 3.0)
    assert(@sampleClass.non_zero_dollar_float? 3.00)
    assert(@sampleClass.non_zero_dollar_float? 3.0000000)
    
    bad_args = ["", 0, {}, [], 6.6600000001, Object.new]
    bad_args.each { |bad_arg| 
      refute(@sampleClass.non_zero_dollar_float?(bad_arg))
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
  
  it "Does checkCurrency work?" do
    good_args = ["0.01", "10", "10.5", "0", "5."]
    good_args.each do |good_arg| 
      assert(@sampleClass.checkCurrency(good_arg))
    end
    
    bad_args = ["garbage", "0.0001", "-5.00", "-5", "5.00x", "5x"]
    bad_args.each do |bad_arg| 
      refute(@sampleClass.checkCurrency(bad_arg))
    end
  end
  
end