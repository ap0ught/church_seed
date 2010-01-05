class Component < ActiveRecord::Base
  belongs_to :page, :counter_cache => true
  belongs_to :source, :class_name => "Page", :foreign_key => :source_page

  has_many :documents

  validates_presence_of :title

  acts_as_list :scope => :page_id

  before_save :strip_quotations
    
  # Strip any speech marks and replace with a marker
  def strip_quotations
    text.gsub!(/["]/, '[s-mark]') unless !self.text_changed?
  end
  
  def snippets
    if snippet_class == "Event"
      Event.future_events(DateTime.now.year, DateTime.now.month, limit)
    else
      snippet_class.constantize.find(:all, :order => order, :limit => limit, :conditions => {:page_id => source_page})
    end
  end
  
  def page_feed?
    component_type == "pagefeed"
  end
  
  def documents?
    component_type == "documents"
  end
  
  def text?
    component_type == "text"
  end
  
  def ordered_documents
    self.documents.find(:all, :order => order)
  end
  
  ORDER_OPTIONS = [
    [ 'Created Descending', 'created_at DESC' ],
    [ 'Created Ascending', 'created_at ASC' ],
    [ 'Title Descending', 'title DESC' ],
    [ 'Title Ascending', 'title ASC' ]
  ]
  
  LIMIT_OPTIONS = [
    [ '1 Item', 1 ],
    [ '3 Items', 3 ],
    [ '5 Items', 5 ],
    [ '10 Items', 10 ]
  ]
end
