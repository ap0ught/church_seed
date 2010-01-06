require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  def setup
    @page = Page.new(:title => 'Page', :name => 'Page', :parent_id => 1002)
    @page.id = 1001
    
    Page.stubs(:find).returns(@page)
    Page.stubs(:find).with(:all).returns([@page])
    
    @valid = {:name => 'Name', :title => 'Title'}
  end
  
  context "as admin" do
    setup do
      login_as :admin
    end
    
    context "getting index" do
      setup do
        Role.expects(:pages_for_viewable_by).returns([@page]).once
        Role.expects(:pages_for_editable_by).returns([@page]).once
        
        Page.expects(:all_parents).returns([@page]).once
        
        get :index
      end
      
      should_assign_to(:viewable){[@page]}
      should_assign_to(:editable){[@page]}
      should_assign_to(:parents){['parent_0', 'parent_00', 'parent_1002']}
      should_respond_with :success
      should_render_with_layout
      should_render_template :index
      should_not_set_the_flash
    end
    
    context "getting show" do
      context "when id is login" do
        setup do
          get :show, :id => 'login'
        end
        
        should_redirect_to("home page"){home_path}
      end
      
      context "when id is a valid page" do
        setup do
          get :show, :id => 1
        end
        
        should_assign_to(:page){@page}
        should_redirect_to("articles page"){resources_path(@page)}
      end
    end
    
    context "getting new" do
      setup do
        get :new
      end
      
      should_assign_to :page, :class => Page
      should_respond_with :success
      should_render_with_layout
      should_render_template :new
      should_not_set_the_flash
      
      should "set menu type to primary" do
        assert_equal 'primary', assigns(:page).menu_type
      end
    end
    
    context "posting create" do
      context "with valid data" do
        setup do
          Page.stubs(:new).returns(@page)
          Page.any_instance.expects(:save).returns(true).once
          post :create, :page => @valid
        end
        
        should_assign_to :page, :class => Page
        should_redirect_to("index page"){resources_path(@page)}
        should_set_the_flash_to "Page was successfully created"
      end

      context "with invalid data" do
        setup do
          Page.any_instance.expects(:save).returns(false).once
          post :create, :page => @valid
        end
        
        should_assign_to :page, :class => Page
        should_respond_with :success
        should_render_with_layout
        should_render_template :new
        should_not_set_the_flash
      end
    end

    context "getting edit" do
      setup do
        get :edit, :id => 1
      end
      
      should_assign_to(:page){@page}
      should_respond_with :success
      should_render_with_layout
      should_render_template :edit
      should_not_set_the_flash
    end

    context "updating" do
      context "with valid data" do
        setup do
          @page.expects(:update_attributes).returns(true).once
          put :update, :id => 1, :page => {}
        end
        
        should_assign_to(:page){@page}
        should_redirect_to("index page"){resources_path(@page)}
        should_set_the_flash_to "Page was successfully updated"
      end

      context "with invalid data" do
        setup do
          @page.expects(:update_attributes).returns(false).once
          put :update, :id => 1, :page => {}
        end
        
        should_assign_to(:page){@page}
        should_respond_with :success
        should_render_with_layout
        should_render_template :edit
        should_not_set_the_flash
      end
    end
    
    context "destroying" do
      context "an allowed page" do
        setup do
          @page.expects(:destroy)
          delete :destroy, :id => 1
        end
        
        should_assign_to(:page){@page}
        should_redirect_to("home page"){home_path}
        should_set_the_flash_to "Page deleted"
      end

      context "a disallowed page" do
        setup do
          @page.id = 1
          delete :destroy, :id => 1
        end
        
        should_assign_to(:page){@page}
        should_redirect_to("home page"){home_path}
        should_set_the_flash_to /^Can't delete/
      end
    end
  end
  
  context "as a member" do
    setup do
      login_as :quentin
    end
    
    should_not_authorize_for :index, :new, :create, :edit, :update, :destroy

    context "getting show" do
      context "when id is login" do
        setup do
          get :show, :id => 'login'
        end
        
        should_redirect_to("home page"){home_path}
      end
      
      context "when id is a valid page" do
        setup do
          get :show, :id => 1
        end
        
        should_assign_to(:page){@page}
        should_redirect_to("articles page"){resources_path(@page)}
      end
    end
  end

  context "as a visitor" do
    should_require_login_for :index, :new, :create, :edit, :update, :destroy

    context "getting show" do
      context "when id is login" do
        setup do
          get :show, :id => 'login'
        end
        
        should_redirect_to("home page"){home_path}
      end
      
      context "when id is a valid page" do
        setup do
          get :show, :id => 1
        end
        
        should_assign_to(:page){@page}
        should_redirect_to("articles page"){resources_path(@page)}
      end
    end
  end
    
  protected
  
  def resources_path(page)
    eval ("#{page.kind}_path(#{page.id})") 
  end

end
