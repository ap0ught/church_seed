require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  class << self
    def should_act_as_logged_in(type, user)
      context "as #{type}" do
        setup do
          @image = Image.new(:thumbnail => 'thumb100', :width => 100, :height => 100, :size => 100, :filename => 'test.jpg', :content_type => 'image/jpg')
          Image.stubs(:find).returns(@image)
          
          login_as user
        end
        
        context "getting new" do
          setup do
            get :new
          end
          
          should_assign_to :image, :class => Image
          should_respond_with :success
          should_render_without_layout
          should_render_template :new
          should_not_set_the_flash
        end
      
        context "posting create" do
          setup do
            Image.any_instance.stubs(:public_filename).returns('')
            Image.any_instance.expects(:save).returns(true)
            post :create, :image => {}
          end
          
          should_assign_to :image, :class => Image
          should_respond_with :success
          should_render_without_layout
          should_render_template '_image_item'
          should_not_set_the_flash
        end
        
        context "destroying" do
          setup do
            @image.stubs(:destroy).once
            delete :destroy, :id => 1001
          end
          
          should_assign_to(:image){@image}
          should_redirect_to("new"){new_image_path}
          should_not_set_the_flash
        end
      end
    end
    
    def should_require_login_for(*actions)
      actions.each do |action|
        context "attempting to #{action}" do
          setup do
            eval action
          end
          
          should_not_assign_to :image
          should_redirect_to("login"){new_session_path}
          should_not_set_the_flash
        end
      end
    end
  end
  
  should_act_as_logged_in('admin', :admin)
  
  context "as a visitor" do
    should_require_login_for 'get :new', 'post :create', 'delete :destroy'
  end
end
