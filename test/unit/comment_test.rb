require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should_belong_to :post
  
  should_validate_presence_of :name, :email, :comment
  
  should_have_callback :before_create, :check_for_spam
  
  should_have_named_scope :approved, :conditions => ["approved = ?", true]
  should_have_named_scope :unapproved, :conditions => ["approved = ?", false]
  should_have_named_scope :recent, lambda{|*args| {:limit => (args.shift || 10), :conditions => args.shift, :order => 'created_at DESC'} }
  
  context "setting request variables" do
    setup do
      @request = stub(:remote_ip => '1.2.3.4', :env => {'HTTP_USER_AGENT' => 'firefox', 'HTTP_REFERER' => 'http://test.com'})
      @comment = Comment.new
      @comment.request = @request
    end
    
    should "set the user's ip address"  do
      assert_equal '1.2.3.4', @comment.user_ip
    end
    
    should "set the user agent" do
      assert_equal 'firefox', @comment.user_agent
    end
    
    should "set the referrer" do
      assert_equal 'http://test.com', @comment.referrer
    end
  end
  
  context "checking for spam" do
    setup do
      @comment = Comment.new
    end
    
    should "approve if spam is false" do
      Akismetor.stubs(:spam?).returns(false)
      @comment.check_for_spam
      assert @comment.approved
    end
    
    should "deny if spam is true" do
      Akismetor.stubs(:spam?).with(@comment.akismet_attributes).returns(true)
      @comment.check_for_spam
      assert !@comment.approved
    end
  end
  
  should "mark as spam" do
    comment = Comment.new
    comment.expects(:update_attribute).with(:approved, false).once
    Akismetor.expects(:submit_spam).with(comment.akismet_attributes).once
    comment.mark_as_spam!
  end
  
  should "mark as ham" do
    comment = Comment.new
    comment.expects(:update_attribute).with(:approved, true).once
    Akismetor.expects(:submit_ham).with(comment.akismet_attributes).once
    comment.mark_as_ham!
  end
  
  context "akismet attributes" do
    setup do
      APP_CONFIG[:akismet_key] = '123'
      APP_CONFIG[:site_url] = 'http://site.com'
      @comment = Comment.new(:user_ip => '1.2.3.4', :user_agent => 'firefox', :name => 'Name', :email => 'email@test.com', :website => 'http://website.com', :comment => 'Comment')
      @attribs = @comment.akismet_attributes
    end
    
    should "set the key to config's akisment key" do
      assert_equal '123', @attribs[:key]
    end
    
    should "set the blog to config's site url" do
      assert_equal 'http://site.com', @attribs[:blog]
    end
    
    should "set the user ip" do
      assert_equal '1.2.3.4', @attribs[:user_ip]
    end
    
    should "set the user agent" do
      assert_equal 'firefox', @attribs[:user_agent]
    end
    
    should "set the comment author" do
      assert_equal 'Name', @attribs[:comment_author]
    end
    
    should "set the comment author e-mail" do
      assert_equal 'email@test.com', @attribs[:comment_author_email]
    end
    
    should "set the comment author url" do
      assert_equal 'http://website.com', @attribs[:comment_author_url]
    end
    
    should "set the comment content" do
      assert_equal 'Comment', @attribs[:comment_content]
    end
  end
end
