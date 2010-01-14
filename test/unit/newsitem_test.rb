require 'test_helper'

class NewsitemTest < ActiveSupport::TestCase
  should "only find newsitem articles" do
    included = Article.create(:title => 'included', :article_type => 'news', :type => 'Newsitem')
    excluded = Article.create(:title => 'excluded', :article_type => 'article')
    assert_equal 2, Article.count
    
    assert_equal [included.id], Newsitem.find(:all).map(&:id)
  end

  should "not be sortable" do
    assert !Newsitem.new.sortable?
  end
end
