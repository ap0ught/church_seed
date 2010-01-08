class Event < ActiveRecord::Base
  
  belongs_to :page
  validates_presence_of :name
  
  named_scope :future_events, lambda{|*args| from = Date.new(args[0] || Date.today.year, args[1] || Date.today.month); { :conditions => ['datetime >= ? or from_date >= ?', from, from], :order => 'datetime, from_date ASC', :limit => (args[2] || 30) } }
  
  def self.current_month_events(year, month, page)
    from = Date.new(year, month, 1)
    to = Date.new(year, next_month(month), 1)
    find(:all, :conditions => ["page_id = ? AND datetime BETWEEN ? AND ? OR from_date BETWEEN ? AND ? OR to_date BETWEEN ? AND ?", page.id, from, to, from, to, from, to], :order => "datetime, from_date ASC")
  end
  
  def sortable?
    false
  end
  
  def date
    (all_day?) ? from_date : datetime
  end
  
  def to_param
    "#{id}-#{permalink}" unless id.nil?
  end

  def permalink
    name.downcase.gsub(/[^a-z1-9]+/i, '-') unless name.nil?
  end
  
  def title
    name
  end
  
  def component_preview
    if all_day?
      todate = "<br />#{to_date.strftime("%A, %d %B")}" unless to_date.blank? || to_date == from_date
      fromdate = from_date.strftime("%A, %d %B") 
      "#{fromdate} #{todate}"
    else
      datetime.strftime("%A, %d %B %R")
    end
  end
  
  def calendar_date
    (all_day?) ? from_date : Date.parse(datetime.to_s)
  end
  
  def duration
    all_day ? (to_date - from_date).to_i + 1 : 1
  end
  
  def range
    if duration == 1
      return calendar_date
    else
      date_iterator = from_date - 1.day
      dates = []
      while date_iterator < to_date
        date_iterator += 1.day
        dates << date_iterator
      end
      dates
    end
  end
  
end

private

def days_in_month(year, month)
  Date.new(year, month, -1).day
end

def next_month(month)
  if month == 12
    month = 1
  else
    month = month+1
  end
end
