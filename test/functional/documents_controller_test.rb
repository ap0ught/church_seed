require 'test_helper'

def should_allow_everything_for(type, user)
  context "as #{type}" do
    setup do
      login_as user if user
    end
    
    context "getting new" do
      setup do
        get :new
      end
      
      should_assign_to :document, :class => Document
      should_respond_with :success
      should_render_without_layout
      should_not_set_the_flash
    end
    
    context "creating" do
      context "with valid data" do
        setup do
          Document.any_instance.stubs(:save).returns(true)
          post :create, :document => {}
        end
        
        should_assign_to :document, :class => Document
        should_respond_with :success
        should_render_without_layout
        should_not_set_the_flash
      end
      
      context "with invalid data" do
        setup do
          Document.any_instance.stubs(:save).returns(false)
          post :create, :document => {}
        end
        
        should_assign_to :document, :class => Document
        should_respond_with :success
        should_render_without_layout
        should_not_set_the_flash
      end
    end
    
    context "destroying" do
      setup do
        @document = Document.new
        Document.stubs(:find).returns(@document)
        
        @document.expects(:destroy).once
        delete :destroy, :id => 1
      end
      
      should_assign_to(:document){@document}
      should_respond_with :success
      should_render_without_layout
      should_not_set_the_flash
    end
  end
end

class DocumentsControllerTest < ActionController::TestCase
  should_allow_everything_for('admin', :admin)
  should_allow_everything_for('a member', :quentin)
  
  context "as a visitor" do
    should_require_login_for :new, :create, :destroy
  end
end
