require 'test_helper'

def should_allow_everything_for(type, user)
  context "as #{type}" do
    setup do
      @page = Factory.build(:page)
      @page.id = 1001
      Page.stubs(:find).returns(@page)

      @article = Factory.build(:article)
      @article.id = 1001
      Article.stubs(:find).returns(@article)
      
      @articles = [@article]
      @articles.stubs(:total_pages).returns(1)
      
      @page.stubs(:articles).returns(@articles)
      @page.articles.stubs(:paginate).returns(@articles)

      login_as user
    end
    
    context "getting index" do
      context "when page_id is 1" do
        setup do
          @page.id = 1
          @page.articles.expects(:paginate).with(:page => '1', :per_page => 10).returns(@articles)
          get :index, :page => '1', :page_id => 1
        end

        should_assign_to(:articles){@articles}
        should_respond_with :success
        should_render_with_layout
        should_render_template 'homepage/index'
        should_not_set_the_flash
      end
      
      context "when page_id isn't 1" do
        setup do
          @page.articles.expects(:paginate).with(:page => '1', :per_page => 10).returns(@articles)
          get :index, :page => '1', :page_id => 1
        end

        should_assign_to(:articles){@articles}
        should_respond_with :success
        should_render_with_layout
        should_render_template 'articles/index'
        should_not_set_the_flash
      end
    end

    context "getting new" do
      setup do
        get :new, :page_id => 1
      end
      
      should_assign_to :article, :class => Article
      should_assign_to(:images){[]}

      should_respond_with :success
      should_render_with_layout
      should_render_template :new
      should_not_set_the_flash
    end
    
    context "posting create" do
      context "with valid data" do
        setup do
          Article.any_instance.expects(:save).returns(true)
          post :create, :page_id => '1', :article => {}
        end
        
        should_assign_to :article, :class => Article
        should_redirect_to("index page"){resource_index_page(@article)}
        should_set_the_flash_to "Article was successfully created"
      end
      
      context "with invalid data" do
        setup do
          Article.any_instance.expects(:save).returns(false)
          post :create, :page_id => '1', :article => {}
        end
        
        should_assign_to :article, :class => Article
        should_respond_with :success
        should_render_with_layout
        should_render_template :new
        should_not_set_the_flash
      end
    end
    
    context "getting edit" do
      setup do
        get :edit, :page_id => 1, :id => @article.id
      end
      
      should_assign_to(:article){@article}
      should_respond_with :success
      should_render_with_layout
      should_render_template :edit
      should_not_set_the_flash
    end
    
    context "updating" do
      context "with valid data" do
        setup do
          @article.expects(:update_attributes).returns(true)
          put :update, :id => 1, :page_id => 1, :article => {}
        end
        
        should_assign_to(:article){@article}
        should_redirect_to("index page"){resource_index_page(@article)}
        should_set_the_flash_to "Article was successfully updated"
      end
      
      context "with invalid data" do
        setup do
          @article.expects(:update_attributes).returns(false)
          put :update, :id => 1, :page_id => 1, :article => {}
        end
        
        should_assign_to(:article){@article}
        should_respond_with :success
        should_render_with_layout
        should_render_template :edit
        should_not_set_the_flash
      end
    end
    
    context "destroying" do
      setup do
        @article.expects(:destroy)
        delete :destroy, :id => 1, :page_id => 1
      end
      
      should_assign_to(:article){@article}
      should_redirect_to("index page"){resource_index_page(@article)}
      should_not_set_the_flash
    end
  end
end

class ArticlesControllerTest < ActionController::TestCase
  should_allow_everything_for('admin', :admin)  
  should_allow_everything_for('a member', :quentin)

  context "as a visitor" do
    should_require_login_for :new, :create, :edit, :update, :destroy

    context "getting index" do
      setup do
        @page = Factory.build(:page)

        @article = Factory.build(:article)
        @article.id = 1001
        Article.stubs(:find).returns(@article)
        
        @articles = [@article]
        @articles.stubs(:total_pages).returns(1)
      end
      
      context "when page_id is 1" do
        setup do
          @page.id = 1
          Page.expects(:find).returns(@page)

          @page.articles.expects(:paginate).with(:page => '1', :per_page => 10).returns(@articles)
          get :index, :page => '1', :page_id => 1
        end

        should_assign_to(:articles){@articles}
        should_respond_with :success
        should_render_with_layout
        should_render_template 'homepage/index'
        should_not_set_the_flash
      end
      
      context "when page_id isn't 1" do
        setup do
          @page.id = 1001
          Page.expects(:find).returns(@page)

          @page.articles.expects(:paginate).with(:page => '1', :per_page => 10).returns(@articles)
          get :index, :page => '1', :page_id => 1
        end

        should_assign_to(:articles){@articles}
        should_respond_with :success
        should_render_with_layout
        should_render_template 'articles/index'
        should_not_set_the_flash
      end
    end
  end  

  protected

  def resource_index_page(resource)
    case resource.article_type
      when 'post' then posts_path(resource.page_id)
      when 'news' then newsitems_path(resource.page_id)
      else articles_path(resource.page_id)
    end
  end
end
