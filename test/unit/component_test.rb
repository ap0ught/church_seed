require 'test_helper'

class ComponentTest < ActiveSupport::TestCase
  should_belong_to :page
  should_belong_to :source, :class_name => "Page", :foreign_key => :source_page
  
  should_have_many :documents
  
  should_validate_presence_of :title
  
  should_act_as_list :scope => :page_id

  should_have_callback :before_save, :strip_quotations
  
  context "stripping quotations" do
    setup do
      @component = Component.new(:text => 'This is a "test".')
    end
    
    should "strip quotations if text has changed" do
      @component.stubs(:text_changed?).returns(true)
      @component.strip_quotations
      assert_equal 'This is a [s-mark]test[s-mark].', @component.text
    end

    should "not strip quotations if text has changed" do
      @component.stubs(:text_changed?).returns(false)
      @component.strip_quotations
      assert_equal 'This is a "test".', @component.text
    end
  end
  
  context "snippets" do
    should "find future events if snippet is an Event" do
      component = Component.new(:snippet_class => 'Event', :order => 'id', :limit => 17, :source_page => 1001)
      event = mock()
      Event.expects(:future_events).with(anything, anything, 17).returns([event]).once
      assert_equal [event], component.snippets
    end
    
    should "perform a find on the snippet class if it's not an Event" do
      component = Component.new(:snippet_class => 'Article', :order => 'id', :limit => 17, :source_page => 1001)
      object = mock()
      Article.expects(:find).with(:all, :order => 'id', :limit => 17, :conditions => {:page_id => 1001}).returns([object])
      assert_equal [object], component.snippets
    end
  end
  
  {'pagefeed' => :page_feed?, 'documents' => :documents?, 'text' => :text?}.each do |type, method|
    context type do
      should "return true if component type is #{type}" do
        component = Component.new(:component_type => type)
        assert component.send(method)
      end
      
      should "return false if component type is not #{type}" do
        component = Component.new(:component_type => 'turkey')
        assert !component.send(method)
      end
    end
  end  
  
  should "find ordered documents" do
    component = Component.new(:order => 'id')
    document = Document.new
    component.documents.expects(:find).with(:all, :order => 'id').returns([document]).once
    assert_equal [document], component.ordered_documents
  end
  
  context "ORDER_OPTIONS" do
    should "include Created Descending" do
      assert Component::ORDER_OPTIONS.include?(['Created Descending', 'created_at DESC'])
    end
    
    should "include Created Ascending" do
      assert Component::ORDER_OPTIONS.include?(['Created Ascending', 'created_at ASC'])
    end
    
    should "include Title Descending" do
      assert Component::ORDER_OPTIONS.include?(['Title Descending', 'title DESC'])
    end
    
    should "include Title Ascending" do
      assert Component::ORDER_OPTIONS.include?(['Title Ascending', 'title ASC'])
    end
    
    should "include four options" do
      assert_equal 4, Component::ORDER_OPTIONS.size
    end
  end
  
  context "LIMIT_OPTIONS" do
    should "include 1 item" do
      assert Component::LIMIT_OPTIONS.include?(['1 Item', 1])
    end
    
    should "include 3 items" do
      assert Component::LIMIT_OPTIONS.include?(['3 Items', 3])
    end
    
    should "include 5 items" do
      assert Component::LIMIT_OPTIONS.include?(['5 Items', 5])
    end
    
    should "include 10 items" do
      assert Component::LIMIT_OPTIONS.include?(['10 Items', 10])
    end
    
    should "include four options" do
      assert_equal 4, Component::LIMIT_OPTIONS.size
    end
  end
end
