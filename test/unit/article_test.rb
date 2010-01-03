require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  should_belong_to :page
  should_have_many :images
  should_have_many :documents
  
  should_validate_presence_of :title
  
  should_act_as_list
  
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
end
