require 'test_helper'

class NewsitemsControllerTest < ActionController::TestCase
  class << self
    def should_get_index
      context "getting index" do
        setup do
          @page.newsitems.expects(:paginate).with(:page => '1', :per_page => 10, :order => 'created_at DESC').returns(@newsitems)
          get :index, :page => '1', :page_id => 1
        end

        should_assign_to(:newsitems){@newsitems}
        should_respond_with :success
        should_render_with_layout
        should_render_template 'newsitems/index'
        should_not_set_the_flash
      end
    end
    
    def should_get_show
      context "getting show" do
        setup do
          @page.newsitems.expects(:find).returns(@newsitem).once
          get :show, :id => 1
        end
        
        should_assign_to(:newsitem){@newsitem}
        should_respond_with :success
        should_render_with_layout
        should_render_template :show
        should_not_set_the_flash
      end
    end
    
    def should_get_archive    
      context "getting archive" do
        context "with year and month" do
          setup do
            Newsitem.expects(:find_all_in_month).with(2009, 12, '1', @page).returns(@newsitems)
            get :archive, :page_id => 1, :page => '1', :year => '2009', :month => '12'
          end
          
          should_assign_to(:newsitems){@newsitems}
          should_respond_with :success
          should_render_with_layout
          should_render_template :index
          should_not_set_the_flash
        end
        
        context "with only the year" do
          setup do
            Newsitem.expects(:find_all_in_year).with(2009, '1', @page).returns(@newsitems)
            get :archive, :page_id => 1, :page => '1', :year => '2009'
          end
          
          should_assign_to(:newsitems){@newsitems}
          should_respond_with :success
          should_render_with_layout
          should_render_template :index
          should_not_set_the_flash
        end
      end
    end
    
    def should_allow_everything_for(type, user)
      context "as #{type}" do
        setup do
          @page = Factory.build(:page)
          @page.id = 1001
          Page.stubs(:find).returns(@page)

          @article = Factory.build(:article, :created_at => Time.now)
          @article.id = 1001
          Article.stubs(:find).returns(@article)
          Article.stubs(:find).with(:all, any_parameters).returns([@article])

          @newsitem = Factory.build(:newsitem, :created_at => Time.now)
          @newsitem.id = 1001
          Newsitem.stubs(:find).returns(@newsitem)
          
          @newsitems = [@newsitem]
          @newsitems.stubs(:total_pages).returns(1)
          
          @page.stubs(:newsitems).returns(@newsitems)
          @page.newsitems.stubs(:paginate).returns(@newsitems)

          login_as user
        end
       
        should_get_index 
        should_get_show
        should_get_archive

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
  end
  
  should_allow_everything_for('admin', :admin)  
  should_allow_everything_for('a member', :quentin)

  context "as a visitor" do
    setup do
      @page = Factory.build(:page)
      @page.id = 1001
      Page.stubs(:find).returns(@page)

      @article = Factory.build(:article, :created_at => Time.now)
      @article.id = 1001
      Article.stubs(:find).returns(@article)
      Article.stubs(:find).with(:all, any_parameters).returns([@article])

      @newsitem = Factory.build(:newsitem, :created_at => Time.now)
      @newsitem.id = 1001
      Newsitem.stubs(:find).returns(@newsitem)
      
      @newsitems = [@newsitem]
      @newsitems.stubs(:total_pages).returns(1)
    end
    
    should_require_login_for :new, :create, :edit, :update, :destroy

    should_get_index
    should_get_show 
    should_get_archive
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
