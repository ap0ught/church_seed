require 'test_helper'

def should_pass_logged_in_as(title, user)
  context "as #{title}" do
    setup do
      @page = Factory.build(:page, :parent_id => 1002, :kind => "articles")
      @page.id = 1001
      Page.stubs(:find).returns(@page)
      Page.stubs(:find).with(:all, any_parameters).returns([@page])
      
      @component = Component.new(:title => 'Title')
      Component.stubs(:find).returns(@component)
      
      login_as user
    end
    
    context "getting new" do
      setup do
        get :new, :page_id => '1001'
      end
      
      should_assign_to :component, :class => Component
      should_respond_with :success
      should_render_with_layout
      should_render_template :new
      should_not_set_the_flash 
    end
    
    context "creating" do
      context "with valid data" do
        context "with source page" do
          setup do
            Component.any_instance.expects(:save).returns(true)
            post :create, :component => {:source_page => '1001'}
          end
          
          should_assign_to :component, :class => Component
          should_redirect_to("articles index"){{:controller => 'articles'}}
          should_set_the_flash_to "Component was successfully created"
          
          should "set the snippet class to Article" do
            assert_equal 'Article', assigns(:component).snippet_class
          end
        end
        
        context "without source page" do
          setup do
            Component.any_instance.expects(:save).returns(true)
            post :create, :component => {}
          end
          
          should_assign_to :component, :class => Component
          should_redirect_to("articles index"){{:controller => 'articles'}}
          should_set_the_flash_to "Component was successfully created"
          
          should "not set the snippet class to Article" do
            assert_nil assigns(:component).snippet_class
          end
        end
      end
      
      context "with invalid data" do
        setup do
          Component.any_instance.expects(:save).returns(false)
          post :create, :component => {}
        end
        
        should_assign_to :component, :class => Component
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
      
      should_assign_to(:component){@component}
      should_respond_with :success
      should_render_with_layout
      should_render_template :edit
      should_not_set_the_flash
    end
    
    context "updating" do
      context "with valid data" do
        context "with source page" do
          setup do
            @component.expects(:update_attributes).with('source_page' => '1001', 'snippet_class' => 'Article').returns(true).once
            put :update, :id => 1, :page_id => '1001', :component => {:source_page => '1001'}
          end
          
          should_assign_to(:component){@component}
          should_redirect_to("articles page"){ {:controller => 'articles'} }
          should_set_the_flash_to "Component was successfully updated"
        end
        
        context "without source page" do
          setup do
            @component.expects(:update_attributes).with({}).returns(true).once
            put :update, :id => 1, :page_id => '1001', :component => {}
          end
          
          should_assign_to(:component){@component}
          should_redirect_to("articles page"){ {:controller => 'articles'} }
          should_set_the_flash_to "Component was successfully updated"
        end
      end
      
      context "with invalid data" do
        setup do
          @component.expects(:update_attributes).with({}).returns(false).once
          put :update, :id => 1, :page_id => 1001, :component => {}
        end
        
        should_assign_to(:component){@component}
        should_respond_with :success
        should_render_with_layout
        should_render_template :edit
        should_not_set_the_flash
      end
    end
    
    context "destroying" do
      setup do
        @component.expects(:destroy).once
        delete :destroy
      end
      
      should_assign_to(:component){@component}
      should_redirect_to('articles page'){ {:controller => 'articles'} }
      should_not_set_the_flash
    end
  end
end

class ComponentsControllerTest < ActionController::TestCase
  should_pass_logged_in_as('admin', :admin)
  should_pass_logged_in_as('a member', :quentin)

  context "as a visitor" do
    should_require_login
  end
end
