require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/boot'
  require 'active_record'
  require 'validates_as_time'
rescue LoadError
  require 'rubygems'
  require 'activerecord'
  require File.dirname(__FILE__) + '/../lib/validates_as_time'
end


class TimeTestRecord < ActiveRecord::Base
  def self.columns; []; end
  attr_accessor :due_at
  validates_as_time :due_at
end


class TimeParseTest < Test::Unit::TestCase

  def test_time_parse_method
    t = TimeTestRecord.new(:due_at_string => "2008-01-01 23:59")
    assert t.valid?, "should use Time.parse to parse the time string"
    assert_equal "2008-01-01 23:59", t.due_at.strftime("%Y-%m-%d %H:%M"), "should fill time field based on string assignment"
  end

end

