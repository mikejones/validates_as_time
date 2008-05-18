require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/boot'
  require 'active_record'
  require File.dirname(__FILE__) + '/../../chronic/lib/chronic'
  require 'validates_as_time'
rescue LoadError
  require 'rubygems'
  require 'activerecord'
  require 'chronic'
  require File.dirname(__FILE__) + '/../lib/validates_as_time'
end


class TestRecord < ActiveRecord::Base
  def self.columns; []; end
  attr_accessor :t0, :t1, :t2, :t3, :t4, :t5, :t6, :t7, :t8
  validates_as_time :t0
  validates_as_time :t1, :t2, :format => "%Y %j %H:%M", :allow_nil => false
  validates_as_time :t3, :default => Chronic.parse("next year")
  validates_as_time :t4, :format => "%Y-%m-%d"
  validates_as_time :t5, :message => "is not loved"
  validates_as_time :t6, :minimum => Chronic.parse("2008-01-01 00:00"),
                         :maximum => Chronic.parse("2009-01-01 00:00")
  validates_as_time :t7, :minimum => Chronic.parse("2008-01-01 00:00"),
                         :maximum => Chronic.parse("2009-01-01 00:00"),
                         :too_early => "is too early mate",
                         :too_late => "is too late mate"
  validates_as_time :t8, :allow_nil => false, :blank => "can't be empty"
end


class ValidatesAsTimeTest < Test::Unit::TestCase

  def test_set_string_reflected_in_get_time
    t = TestRecord.new
    t.t0_string = Chronic.parse("2008-01-01 23:59").strftime("%Y-%m-%d %H:%M")
    assert_equal Chronic.parse("2008-01-01 23:59").strftime("%Y-%m-%d %H:%M"),
                 t.t0.strftime("%Y-%m-%d %H:%M"),
                 "it should reflect a set string value via get time value"
  end

  def test_set_string_reflected_in_get_string
    t = TestRecord.new
    t.t0_string = Chronic.parse("2008-01-01 23:59").strftime("%Y-%m-%d %H:%M")
    assert_equal Chronic.parse("2008-01-01 23:59").strftime("%Y-%m-%d %H:%M"),
                 t.t0_string,
                 "it should reflect a set string value via get string value"
  end

  def test_set_time_reflected_in_get_time
    assert_equal Chronic.parse("2008-01-01 23:59").strftime("%Y-%m-%d %H:%M"),
                 TestRecord.new(:t0 => Chronic.parse("2008-01-01 23:59")).t0.strftime("%Y-%m-%d %H:%M"),
                 "it should reflect a set time value via get time value"
  end

  def test_set_time_reflected_in_get_string
    assert_equal Chronic.parse("2008-01-01 23:59").strftime("%Y-%m-%d %H:%M"),
                 TestRecord.new(:t0 => Chronic.parse("2008-01-01 23:59")).t0_string,
                 "it should reflect a set time value via get string value"
  end

  def test_invalid_format
    t = TestRecord.new(:t0_string => "2008-01-99 23:59")
    t.valid?
    assert_equal "is invalid", t.errors[:t0], "invalid format"
    assert_equal nil, t.t0, "time value is not affected by invalid string format after create"
    assert_equal "2008-01-99 23:59", t.t0_string, "string value responds back with given invald string format after create"
    
    t = TestRecord.new(:t0_string => "2008-01-01 23:59")
    t.t0_string = "2008-01-99 23:59"
    t.valid?
    assert_equal "is invalid", t.errors[:t0], "invalid format"
    assert_equal Chronic.parse("2008-01-01 23:59").strftime("%Y %j %H:%M"), 
                 t.t0.strftime("%Y %j %H:%M"), 
                 "time value is not affected by invalid string format after modify"
    assert_equal "2008-01-99 23:59", t.t0_string, "string value responds back with given invald string format after modify"
  end

  def test_multi_attributes
    assert_equal Chronic.parse("now").strftime("%Y %j %H:%M"),
                 TestRecord.new.t1_string,
                 "it should work with multiple attributes #1"
    assert_equal Chronic.parse("now").strftime("%Y %j %H:%M"),
                 TestRecord.new.t2_string,
                 "it should work with multiple attributes #2"
  end

  def test_option_default
    assert_equal Chronic.parse("now").strftime("%Y %j %H:%M"),
                 Chronic.parse(TestRecord.new.t0_string).strftime("%Y %j %H:%M"),
                 "it should work with a default default"
    assert_equal Chronic.parse("next year").year,
                 Chronic.parse(TestRecord.new.t3_string).year,
                "it should work with a custom default"
  end

  def test_option_format
    assert TestRecord.new.t0_string =~ /^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}$/, "it should work with a default format"
    assert TestRecord.new.t4_string =~ /^\d{4}-\d{2}-\d{2}$/, "it should work with a custom format"
  end

  def test_option_message
    t = TestRecord.new(:t0_string => "2008-99-99 23:59")
    t.valid?
    assert_equal "is invalid", t.errors[:t0], "it should work with a default error message"
    t = TestRecord.new(:t5_string => "2008-99-99 23:59")
    t.valid?
    assert_equal "is not loved", t.errors[:t5], "it should work with a custom error message"
  end

  def test_option_minimum
    t = TestRecord.new(:t6_string => "2008-02-02 02:02")
    t.valid?
    assert t.errors[:t6].nil?, "it should allow the value when it's later than a custom minimum time"
    t = TestRecord.new(:t6_string => "2007-12-31 23:59")
    t.valid?
    assert_equal "cannot be before 2008-01-01 00:00", t.errors[:t6], "it should not allow the value when it's earlier than a custom minimum time"
  end

  def test_option_maximum
    t = TestRecord.new(:t6_string => "2008-02-02 02:02")
    t.valid?
    assert t.errors[:t6].nil?, "it should allow the value when it's earlier than a custom maximum time"
    t = TestRecord.new(:t6_string => "2009-01-01 00:00")
    t.valid?
    assert_equal "cannot be on or after 2009-01-01 00:00", t.errors[:t6], "it should not allow the value when it's later than a custom maximum time"
  end

  def test_option_too_early
    t = TestRecord.new(:t7_string => "2007-12-31 23:59")
    t.valid?
    assert_equal "is too early mate", t.errors[:t7], "it should work with a custom too_early message"
  end

  def test_option_too_late
    t = TestRecord.new(:t7_string => "2009-01-01 00:00")
    t.valid?
    assert_equal "is too late mate", t.errors[:t7], "it should work with a custom too_late message"
  end

  def test_option_allow_nil?
    t = TestRecord.new
    t.valid?
    assert t.errors[:t0].nil?, "it should allow nil values by default"
    assert_equal "can't be blank", t.errors[:t1], "it should not allow nil values when custom allow_nil option is set to false"
  end

  def test_option_blank
    t = TestRecord.new
    t.valid?
    assert_equal "can't be empty",
                 t.errors[:t8],
                 "it should show a custom blank message when the custom allow_nil option is set to false and the value is nil"
  end

end

