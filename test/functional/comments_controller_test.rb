require 'test_helper'

def test_for_all
  setup do
      @comment = Comment.new(:post_id => 1002)
      Comment.stubs(:find).returns(@comment)
  end
  
  context "creating" do
    setup do
      Comment.stubs(:new).returns(@comment)
    end
    
    context "with valid data" do
      setup do
        @comment.expects(:save).returns(true).once
        @comment.approved = true
        
        post :create, :comment => {}, :page_id => '1001'
      end
      
      should_redirect_to("post page"){post_path('1001', 1002, :nocache => 't')}
      should_set_the_flash_to "Thanks for the comment"
    end
    
    context "with invalid data" do
      setup do
        @comment.expects(:save).returns(false).once
        post :create, :comment => {}, :page_id => '1001' 
      end
      
      should_redirect_to("post page"){post_path('1001', 1002, :nocache => 't')}
      should_set_the_flash_to "Unfortunately this comment has been flagged as spam. It has been referreed to an administrator"
    end
    
    context "with unapproved comment" do
      setup do
        @comment.expects(:save).returns(true).once
        @comment.approved = false

        post :create, :comment => {}, :page_id => '1001'
      end
      
      should_redirect_to("post page"){post_path('1001', 1002, :nocache => 't')}
      should_set_the_flash_to "Unfortunately this comment has been flagged as spam. It has been referreed to an administrator"
    end
  end
  
  context "destroying multiple" do
    setup do
      Comment.expects(:destroy).once
      delete :destroy_multiple, :comment_ids => [], :page_id => '1001', :postid => '1002'
    end
    
    should_redirect_to("post page"){post_path(1001, 1002)}
    should_set_the_flash_to "Successfully destroyed comments."
  end
  
  context "approving" do
    setup do
      @comment.expects(:mark_as_ham!)
      put :approve, :id => 1, :page_id => '1001'
    end
    
    should_redirect_to("post page"){post_path(1001, 1002)}
  end
  
  context "rejecting" do
    setup do
      @comment.expects(:mark_as_spam!)
      put :reject, :id => 1, :page_id => '1001'
    end
    
    should_redirect_to("post page"){post_path(1001, 1002)}
  end
  
  context "destroying" do
    setup do
      CommentSweeper.any_instance.stubs(:expire_article_index)
      delete :destroy, :id => 1, :page_id => '1001'
    end
    
    should_redirect_to("post page"){post_path(1001, 1002)}
  end
end

class CommentsControllerTest < ActionController::TestCase
  context "as admin" do
    setup do
      login_as :admin
    end

    test_for_all    
  end
  
  context "as a member" do
    setup do
      login_as :quentin
    end
    
    test_for_all
  end
  
  context "as a visitor" do
    test_for_all
  end
end
