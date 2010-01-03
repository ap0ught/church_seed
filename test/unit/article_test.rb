require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  should_belong_to :page
  should_have_many :images
  should_have_many :documents
  
  should_validate_presence_of :title
  
  should_act_as_list
  should_act_as_indexed :fields => [:title, :content]
  
  should "be sortable" do
    article = Article.new
    assert article.sortable?
  end
  
  should "create a link-safe permalink" do
    article = Article.new(:title => 'This is a Test!')
    assert_equal 'this-is-a-test-', article.permalink
  end
  
  should "set a custom to_param" do
    article = Article.new(:title => 'This is a Test!')
    article.id = 1001

    assert_equal '1001-this-is-a-test-', article.to_param
  end
  
  should "replace quotations with s-mark before save" do
    article = Article.new(:title => 'Test', :content => 'This is a "test".')
    article.connection.stubs(:insert)
    
    assert_equal 'This is a "test".', article.content
    article.save
    assert_equal 'This is a [s-mark]test[s-mark].', article.content
  end
  
  context "setting image sizes" do
    should "define small" do
      assert Article::IMAGESIZE.include?(['Small', 'thumb100'])
    end
    
    should "define regular" do
      assert Article::IMAGESIZE.include?([ 'Regular', 'thumb200' ])
    end
    
    should "define medium" do
      assert Article::IMAGESIZE.include?([ 'Medium', 'thumb300' ])
    end
    
    should "define large" do
      assert Article::IMAGESIZE.include?([ 'Large', 'thumb400' ])
    end
  end
  
  should "return parsed video link" do
    article = Article.new(:video => 'http://www.youtube.com/watch?v=HJQcol7HevI')
    assert_equal 'http://www.youtube.com/v/HJQcol7HevI', article.parsed_video
  end
  
  context "showing component preview" do
    should "display a sorry message if type is documents" do
      article = Article.new(:article_type => 'documents')
      assert_equal 'Preview not available...', article.component_preview
    end
    
    should "display the first 100 characters of content if type is not documents" do
      article = Article.new(:article_type => 'article', :content => ("abcde" * 100))
      assert_equal ('abcde' * 20) + '...', article.component_preview
    end
  end
  
  context "finding articles" do
    setup do
      @page = Factory.build(:page)
      @page.id = 1001
      @page.stubs(:paginate).returns(10)
    end

    should "show all the articles for this page in a given month, with pagination" do
      Article.expects(:paginate).with(
        :page => 1, :per_page => 10, :order => 'created_at DESC',
        :conditions => ["page_id = ? AND created_at BETWEEN ? AND ?", 1001, DateTime.new(2009, 1, 1), DateTime.new(2009, 1, 31, 11, 59, 59)]
      ).once
      Article.find_all_in_month(2009, 1, 1, @page)
    end
    
    should "show all the articles for this page in a given year, with pagination" do
      Article.expects(:paginate).with(
        :page => 1, :per_page => 10, :order => 'created_at DESC',
        :conditions => ["page_id = ? AND created_at BETWEEN ? AND ?", 1001, DateTime.new(2009, 1, 1), DateTime.new(2009, 12, 31, 11, 59, 59)]
      ).once
      Article.find_all_in_year(2009, 1, @page)
    end
    
    should "find archive links" do
      articles = [Factory.build(:article, :created_at => '2008-08-08'), Factory.build(:article, :created_at => '2009-09-09')]
      Article.expects(:find).with(:all, :select => "created_at", :conditions => ["page_id = ?", 1001]).returns(articles).once
      
      results = Article.archive_links(@page)
      assert_equal [['2009', [articles[1]]], ['2008', [articles[0]]]], results
    end
  end
end
