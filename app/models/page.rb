class Page < ActiveRecord::Base
  has_many :articles, :order => :position, :dependent => :destroy
  has_many :newsitems, :order => :position, :dependent => :destroy, :include => :images
  has_many :posts, :order => :position, :dependent => :destroy, :include => :images
  has_many :components, :order => :position, :dependent => :destroy
  has_many :events, :order => "datetime, from_date ASC", :dependent => :destroy
  
  validates_presence_of :title, :name

  acts_as_tree :order => :position
  acts_as_list :scope => :parent
  
  named_scope :pages_menu, lambda{|*args| {:conditions => {:parent_id => nil, :menu_type => (args.first || 'primary')}, :include => :children, :order => 'position'} }
  named_scope :all_parents, :select => 'parent_id', :conditions => 'parent_id is not null', :group => 'parent_id'
  named_scope :siblings_of, lambda{|*args| {:conditions => {:parent_id => (args.first && args.first.is_a?(Page) ? args.first.parent_id : nil)}, :order => 'position' } }
  named_scope :all_pages_for_dropdown, lambda{|*args| {:id => (args.first || nil), :parent_id => nil} }

  before_destroy :dont_delete_home_page
  
  def flat_child_links
    self.parent_id ? self.class.siblings_of(self) : self.children
  end
  
  def requires_sidebar?
    !self.children.empty? || self.parent_id || !self.components.empty?
  end
  
  def permalink
    name.downcase.gsub(/[^a-z1-9]+/, '-') unless name.nil?
  end
  
  def to_param
    "#{id}-#{permalink}"
  end
  
  def dont_delete_home_page
    if self.id == 1
      raise "Can't delete the Home page"
    end
  end
  
  def public?
    viewable_by == "public" 
  end
  
  def private?
    viewable_by == "all users" 
  end
  
  def all_users?
    true if editable_by == "all users" 
  end
  
  MENUS = [
    [ 'Primary Menu', 'primary' ],
    [ 'Secondary Menu', 'secondary' ]
  ]
  
  KIND = [
    [ 'General  - Text, Images, Video, Table', 'articles' ],
    [ 'News     - News items with dates and archive section', 'newsitems' ],
    [ 'Calendar - Calendar event items', 'events' ],
    [ 'Blog     - Dated articles with comments', 'posts' ]
  ]
  
  PAGINATION = [
    [ 'No Pagination', '' ],
    [ '5 Items per page', 5 ],
    [ '10 Items per page', 10 ],
    [ '20 Items per page', 20 ],
    [ '50 Items per page', 50 ]
  ]
  
  def self.pages_for_parent_select(page, action)
    conditions = {:menu_type => page.menu_type, :parent_id => nil}
    conditions = ["id != ?", page.id, conditions] unless action == 'new'

    [Page.new(:name => 'Top Level')] + Page.find(:all, :select => "id, name, parent_id", :conditions => conditions, :order => "position ASC")
  end
  
  def self.parent_select(page)
    [Page.new(:name => "Top Level")] + Array(Page.find(:all, :select => "id, name", :conditions => {:parent_id => nil, :menu_type => page.menu_type}, :order => "position"))
  end
  
  def name_for_parent_menu
    parent_id ? "- #{name}" : name
  end

  # Use the parent_id for the menu list_level class
  def tree_level
    parent_id || 0
  end
end
