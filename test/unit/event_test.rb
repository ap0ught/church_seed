require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should_belong_to :page
  should_validate_presence_of :name
  
  should_have_named_scope :future_events, lambda{|*args| from = Date.new(args[0], args[1]); { :conditions => ['datetime >= ? or from_date >= ?', from, from], :order => 'datetime, from_date ASC', :limit => (args[2] || 30) } }
  
  should "not be sortable" do
    assert !Event.new.sortable?
  end
  
  context "date" do
    setup do
      @event = Event.new(:from_date => '2008-01-01', :datetime => '2009-01-01')
    end
    
    should "be from_date if all day" do
      @event.all_day = true
      assert_equal Date.new(2008, 1, 1), @event.date
    end
    
    should "be dateatime if not all day" do
      @event.all_day = false
      assert_equal DateTime.new(2009, 1, 1), @event.date
    end
  end
  
  context "permalink derived from name" do
    should "be all lowercase" do
      event = Event.new(:name => 'Test')
      assert_equal 'test', event.permalink
    end
    
    should "replace non-alphanumeric characters with dashes" do
      event = Event.new(:name => 'this is a test')
      assert_equal 'this-is-a-test', event.permalink
    end
  end
  
  should "return id-permalink for to_param" do
    event = Event.new(:name => 'This is a Test')
    event.id = 1001
    
    assert_equal '1001-this-is-a-test', event.to_param
  end
  
  should "return title as name" do
    event = Event.new(:name => 'Slappy')
    assert_equal 'Slappy', event.title
  end
  
  context "component_preview" do
    context "when event is all day" do
      context "and to_date is blank (one day)" do
        should "return the single day in european format" do
          event = Event.new(:all_day => true, :from_date => '2010-01-01')
          assert_equal 'Friday, 01 January ', event.component_preview
        end
      end
      
      context "and to and from dates are the same (one day)" do
        should "return the single day in european format" do
          event = Event.new(:all_day => true, :from_date => '2010-01-01', :to_date => '2010-01-01')
          assert_equal 'Friday, 01 January ', event.component_preview
        end
      end
      
      context "and event is multi-day" do
        should "return the day range in european format" do
          event = Event.new(:all_day => true, :from_date => '2010-01-01', :to_date => '2010-01-02')
          assert_equal 'Friday, 01 January <br />Saturday, 02 January', event.component_preview
        end
      end
    end
    
    context "when event is not all day" do
      should "return the day/time in european format" do
        event = Event.new(:all_day => false, :datetime => '2010-01-01 00:00:01')
        assert_equal 'Friday, 01 January 00:00', event.component_preview
      end
    end
  end
  
  context "calendar_date" do
    should "return the from_date if all day event" do
      event = Event.new(:all_day => true, :from_date => '2010-01-01', :datetime => '2010-01-02 00:00:01')
      assert_equal Date.parse('2010-01-01'), event.calendar_date
    end
    
    should "return the datatime's date if not an all day event" do
      event = Event.new(:all_day => false, :from_date => '2010-01-01', :datetime => '2010-01-02 00:00:01')
      assert_equal Date.parse('2010-01-02'), event.calendar_date    
    end
  end
  
  context "duration" do
    context "when all day" do
      should "return 1 if it starts/ends the same day" do
        event = Event.new(:all_day => true, :from_date => '2010-01-01', :to_date => '2010-01-01')
        assert_equal 1, event.duration
      end
      
      should "return 2 if it starts today, ends tomorrow" do
        event = Event.new(:all_day => true, :from_date => '2010-01-01', :to_date => '2010-01-02')
        assert_equal 2, event.duration
      end
    end
    
    context "when not all day" do
      should "return 1" do
        event = Event.new(:all_day => false, :datetime => '2010-01-01 00:00:01')
        assert_equal 1, event.duration
      end
    end
  end
  
  context "range" do
    should "return calendar date if one day" do
      event = Event.new(:all_day => true, :from_date => '2010-01-01', :to_date => '2010-01-01')
      assert_equal Date.parse('2010-01-01'), event.range
    end
    
    should "return an array of calendar dates of multiple days" do
      event = Event.new(:all_day => true, :from_date => '2010-01-01', :to_date => '2010-01-03')
      assert_equal [Date.parse('2010-01-01'), Date.parse('2010-01-02'), Date.parse('2010-01-03')], event.range
    end
  end
end
