require 'test_helper'

class PageTest < ActiveSupport::TestCase
  should_have_many :articles, :order => :position, :dependent => :destroy
  should_have_many :newsitems, :order => :position, :dependent => :destroy, :include => :images
  should_have_many :posts, :order => :position, :dependent => :destroy, :include => :images
  should_have_many :components, :order => :position, :dependent => :destroy
  should_have_many :events, :order => 'datetime, from_date ASC', :dependent => :destroy
  
  should_validate_presence_of :title, :name

  should_act_as_list :scope => :parent
  should_act_as_tree :order => :position

  should_have_named_scope :pages_menu, lambda{|*args| {:conditions => {:parent_id => nil, :menu_type => (args.first || 'primary')}, :include => :children, :order => 'position'} }
  should_have_named_scope :all_parents, :select => 'parent_id', :conditions => 'parent_id is not null', :group => 'parent_id'
  should_have_named_scope :siblings_of, lambda{|*args| {:conditions => {:parent_id => (args.first && args.first.is_a?(Page) ? args.first.parent_id : nil)}, :order => 'position' } }
  should_have_named_scope :all_pages_for_dropdown, lambda{|*args| {:conditions => {:id => (args.first || nil), :parent_id => nil} } }

  should_have_callback :before_destroy, :dont_delete_home_page
  
  context "flat_child_links" do
    should "call siblings if a child" do
      page = Page.new(:parent_id => 1)
      Page.expects(:siblings_of).with(page).returns([1]).once
      assert_equal [1], page.flat_child_links
    end
    
    should "call children if not a child" do
      page = Page.new
      page.expects(:children).returns([2]).once
      assert_equal [2], page.flat_child_links
    end
  end
  
  context "checking if sidebar is required" do
    should "require sidebar if there are children" do
      page = Page.new
      page.stubs(:children).returns([Page.new])
      page.stubs(:components).returns([])
      assert page.requires_sidebar?
    end
    
    should "require sidebar if page is a child" do
      page = Page.new(:parent_id => 1)
      page.stubs(:children).returns([])
      page.stubs(:components).returns([])
      assert page.requires_sidebar?
    end
    
    should "require sidebar if there are components" do
      page = Page.new
      page.stubs(:children).returns([])
      page.stubs(:components).returns([Component.new])
      assert page.requires_sidebar?
    end
    
    should "not require sidebar if no children, parent_id, or components" do
      page = Page.new
      page.stubs(:children).returns([])
      page.stubs(:components).returns([])
      assert !page.requires_sidebar?
    end
  end
  
  context "setting permalink" do
    should "replace non-alphanumeric characters with dashes" do
      assert_equal 'this-is-a-test',  Page.new(:name => 'this is a test').permalink
    end
    
    should "downcase" do
      assert_equal 'test', Page.new(:name => 'Test').permalink
    end
    
    should "return nil for a nil name" do
      assert_nil Page.new(:name => nil).permalink
    end
  end
  
  should "set to_param to id-permalink" do
    page = Page.new(:name => 'This is a test')
    page.id = 1001
    assert_equal '1001-this-is-a-test', page.to_param
  end
  
  context "protecting home page from deletion" do
    setup do
      @page = Page.new
      @page.id = 1
    end
    
    should_raise(:message => "Can't delete the Home page"){@page.dont_delete_home_page}
  end
  
  context "checking if public" do
    should "return true if viewable by public" do
      assert Page.new(:viewable_by => 'public').public?
    end
  
    should "return false if viewable by something unexpected" do
      assert !Page.new(:viewable_by => 'chickens').public?
    end
  end
  
  context "checking if private" do
    should "return true if viewable by all users" do
      assert Page.new(:viewable_by => 'all users').private?
    end
    
    should "return false if viewable by public" do
      assert !Page.new(:viewable_by => 'public').private?
    end
    
    should "return false if viewable by something unexpected" do
      assert !Page.new(:viewable_by => 'chickens').private?
    end
  end
  
  context "checking if editable by all users" do
    should "return true if editable by all users" do
      assert Page.new(:editable_by => 'all users').all_users?
    end
    
    should "return false if editable by public" do
      assert !Page.new(:editable_by => 'public').all_users?
    end
    
    should "return false if editable by something unexpected" do
      assert !Page.new(:editable_by => 'chickens').all_users?
    end
  end
  
  context "MENUS list" do
    should "include primary menu" do
      assert Page::MENUS.include?(['Primary Menu', 'primary'])
    end
    
    should "include secondary menu" do
      assert Page::MENUS.include?(['Secondary Menu', 'secondary'])
    end
  end
  
  context "KIND list" do
    should "include general" do
      assert Page::KIND.include?([ 'General  - Text, Images, Video, Table', 'articles' ])
    end

    should "include news" do
      assert Page::KIND.include?([ 'News     - News items with dates and archive section', 'newsitems' ])
    end

    should "include calendar" do
      assert Page::KIND.include?([ 'Calendar - Calendar event items', 'events' ])
    end

    should "include blog" do
      assert Page::KIND.include?([ 'Blog     - Dated articles with comments', 'posts' ])
    end
  end
  
  context "PAGINATION list" do
    should "include no pagination" do
      assert Page::PAGINATION.include?([ 'No Pagination', '' ])
    end
    
    should "include 5 Items per page" do
      assert Page::PAGINATION.include?([ '5 Items per page', 5 ])
    end
    
    should "include 10 Items per page" do
      assert Page::PAGINATION.include?([ '10 Items per page', 10 ])
    end
    
    should "include 20 Items per page" do
      assert Page::PAGINATION.include?([ '20 Items per page', 20 ])
    end
    
    should "include 50 Items per page" do
      assert Page::PAGINATION.include?([ '50 Items per page', 50 ])
    end
  end
  
  context "pages_for_parent_select" do
    setup do
      @new_page = Page.new(:name => 'Top Level')
      @page = Page.new(:name => 'Existing Page', :menu_type => 'menu_type')
      @page.id = 1001
      
      Page.stubs(:new).returns(@new_page)
    end
    
    should "check id if not new" do
      Page.expects(:find).with(:all, :select => "id, name, parent_id", :order => 'position ASC', :conditions => ['id != ?', 1001, {:menu_type => 'menu_type', :parent_id => nil}]).returns([@page]).once
      assert_equal [@new_page, @page], Page.pages_for_parent_select(@page, 'create')
    end
    
    should "not check id if new" do
      Page.expects(:find).with(:all, :select => "id, name, parent_id", :order => 'position ASC', :conditions => {:menu_type => 'menu_type', :parent_id => nil}).returns([@page]).once
      assert_equal [@new_page, @page], Page.pages_for_parent_select(@page, 'new')
    end
  end
  
  should "find the parent list of a given page (non-child of same menu type)" do
    @new_page = Page.new(:name => 'Top Level')
    @page = Page.new(:name => 'Existing Page', :menu_type => 'menu_type')
    Page.stubs(:new).returns(@new_page)

    Page.expects(:find).with(:all, :select => "id, name", :order => "position", :conditions => {:parent_id => nil, :menu_type => 'menu_type'}).returns([@page]).once
    assert_equal [@new_page, @page], Page.parent_select(@page)
  end
   
  context "name_for_parent_menu" do
    should "use name if non-child" do
      page = Page.new(:name => 'Test', :parent_id => nil)
      assert_equal 'Test', page.name_for_parent_menu
    end
    
    should "use '- name' if child" do
      page = Page.new(:name => 'Test', :parent_id => 1)
      assert_equal '- Test', page.name_for_parent_menu
    end
  end 
  
  context "tree_level" do
    should "be parent_id if child" do
      page = Page.new(:parent_id => 1001)
      assert_equal 1001, page.tree_level
    end
    
    should "be zero if non-child" do
      page = Page.new
      assert_equal 0, page.tree_level
    end
  end
end
