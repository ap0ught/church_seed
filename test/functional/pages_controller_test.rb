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
    
    context "attempting to get index" do
      setup do
        get :index
      end
      
      should_not_assign_to :page
      should_respond_with 401
      should_render_without_layout
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

    context "attempting to get edit" do
      setup do
        get :edit, :id => 1, :page => {}
      end
      
      should_not_assign_to :page
      should_respond_with 401
      should_render_without_layout
      should_not_set_the_flash
    end

    context "attempting to create" do
      setup do
        post :create, :page => {}
      end
      
      should_not_assign_to :page
      should_respond_with 401
      should_render_without_layout
      should_not_set_the_flash
    end

    context "attempting to edit" do
      setup do
        get :edit, :id => 1
      end
      
      should_not_assign_to :page
      should_respond_with 401
      should_render_without_layout
      should_not_set_the_flash
    end

    context "attempting to update" do
      setup do
        put :update, :id => 1, :page => {}
      end
      
      should_not_assign_to :page
      should_respond_with 401
      should_render_without_layout
      should_not_set_the_flash
    end

    context "attempting to destroy" do
      setup do
        delete :destroy, :id => 1
      end
      
      should_not_assign_to :page
      should_respond_with 401
      should_render_without_layout
      should_not_set_the_flash
    end
  end

  context "as a visitor" do
    context "attempting to get index" do
      setup do
        get :index
      end
      
      should_not_assign_to :page
      should_redirect_to("login"){new_session_path}
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

    context "attempting to get edit" do
      setup do
        get :edit, :id => 1, :page => {}
      end
      
      should_not_assign_to :page
      should_redirect_to("login"){new_session_path}
      should_not_set_the_flash
    end

    context "attempting to create" do
      setup do
        post :create, :page => {}
      end
      
      should_not_assign_to :page
      should_redirect_to("login"){new_session_path}
      should_not_set_the_flash
    end

    context "attempting to edit" do
      setup do
        get :edit, :id => 1
      end
      
      should_not_assign_to :page
      should_redirect_to("login"){new_session_path}
      should_not_set_the_flash
    end

    context "attempting to update" do
      setup do
        put :update, :id => 1, :page => {}
      end
      
      should_not_assign_to :page
      should_redirect_to("login"){new_session_path}
      should_not_set_the_flash
    end

    context "attempting to destroy" do
      setup do
        delete :destroy, :id => 1
      end
      
      should_not_assign_to :page
      should_redirect_to("login"){new_session_path}
      should_not_set_the_flash
    end
  end
    
#  def setup
#    @valid = {:title => 'Page', :name => 'Page'}
#  end

#  def test_as_admin_getting_index_should_succeed
#    login_as :admin
#    get :index
#    assert_response :success
#    
#    assert_not_nil assigns(:viewable)
#    assert assigns(:viewable).is_a?(Array)
#    
#    assert_not_nil assigns(:editable)
#    assert assigns(:editable).is_a?(Array)
#    
#    assert_not_nil assigns(:parents)
#    assert assigns(:parents).is_a?(Array)
#    assert_equal ['parent_0', 'parent_00'], assigns(:parents)[0,2]
#  end
#  
#  def test_as_member_getting_index_should_not_be_authorized
#    login_as :quentin
#    get :index
#    assert_response 401
#  end
#  
#  def test_as_visitor_getting_index_should_be_redirected_to_login
#    get :index
#    assert_redirected_to new_session_path
#  end

#  def test_as_admin_getting_new_should_succeed
#    login_as :admin
#    get :new
#    assert_response :success
#  end
#  
#  def test_as_member_getting_new_should_not_be_authorized
#    login_as :quentin
#    get :new
#    assert_response 401
#  end
#  
#  def test_as_visitor_getting_new_should_be_redirected_to_login
#    get :new
#    assert_redirected_to new_session_path
#  end

#  def test_as_admin_creating_page_should_succeed
#    login_as :admin
#    assert_difference('Page.count') do
#      post :create, :page => @valid
#    end

#    assert_redirected_to resources_path(assigns(:page))
#  end
#  
#  def test_as_member_creating_page_should_not_be_authorized
#    login_as :quentin
#    post :create, :page => @valid
#    assert_response 401
#  end

#  def test_as_visitor_creating_page_should_be_redirected_to_login
#    post :create, :page => @valid
#    assert_redirected_to new_session_path
#  end
#  
#  def test_as_admin_showing_page_should_succeed
#    login_as :admin
#    get :show, :id => pages(:one).id
#    assert_redirected_to resources_path(pages(:one))
#  end

#  def test_as_user_showing_page_should_succeed
#    login_as :quentin
#    get :show, :id => pages(:one).id
#    assert_redirected_to resources_path(pages(:one))
#  end

#  def test_as_visitor_showing_page_should_succeed
#    get :show, :id => pages(:one).id
#    assert_redirected_to resources_path(pages(:one))
#  end

#  def test_as_admin_getting_edit_should_succeed
#    login_as :admin
#    get :edit, :id => pages(:one).id
#    assert_response :success
#  end

#  def test_as_member_getting_edit_should_not_be_authorized
#    login_as :quentin
#    get :edit, :id => 1
#    assert_response 401
#  end
#  
#  def test_as_visitor_getting_edit_should_be_redirected_to_login
#    get :edit, :id => 1
#    assert_redirected_to new_session_path
#  end

#  def test_as_admin_updating_page_should_succeed
#    login_as :admin
#    put :update, :id => pages(:one).id, :page => { }
#    assert_redirected_to resources_path(assigns(:page))
#  end
#  
#  def test_as_user_updating_page_should_not_be_authorized
#    login_as :quentin
#    put :update, :id => pages(:one).id, :page => { }
#    assert_response 401
#  end
#  
#  def test_as_visitor_updating_page_should_redirect_to_login
#    put :update, :id => pages(:one).id, :page => { }
#    assert_redirected_to new_session_path
#  end

#  def test_as_admin_destroying_page_should_succeed
#    login_as :admin
#    assert_difference('Page.count', -1) do
#      delete :destroy, :id => pages(:two).id
#    end

#    assert_redirected_to resources_path(pages(:one))
#  end

#  def test_as_member_destroying_page_should_not_be_authorized
#    login_as :quentin
#    delete :destroy, :id => 1
#    assert_response 401
#  end

#  def test_as_admin_destroying_page_should_succeed
#    delete :destroy, :id => 1
#    assert_redirected_to new_session_path
#  end

  protected
  
  def resources_path(page)
    eval ("#{page.kind}_path(#{page.id})") 
  end

end
