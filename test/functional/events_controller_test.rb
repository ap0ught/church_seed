require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  fixtures :roles, :users, :roles_users

  class << self
    def should_succeed_with(template)
      should_respond_with :success
      should_render_with_layout
      should_render_template template
      should_not_set_the_flash
    end
    
    def should_allow(*actions)
      actions = [:index, :show, :new, :create, :edit, :update, :destroy] if actions == [:all]
      actions.each{|action| send "should_allow_#{action}"}
    end
    
    def should_allow_index
      context "getting index" do
        context "when month and year are specified" do
          setup do
            Event.expects(:current_month_events).with(2010, 1, @page).returns(@events)
            get :index, :page_id => 1001, :month => '1', :year => '2010'
          end

          should_assign_to(:month){1}
          should_assign_to(:year){2010}
          should_assign_to(:events){@events}
          should_succeed_with :index
        end
        
        context "when month and year are not specified" do
          setup do
            @today = Date.today
            Date.stubs(:today).returns(@today)
           
            @today.expects(:month).returns(12)
            @today.expects(:year).returns(2012)
            
            Event.expects(:current_month_events).with(2012, 12, @page).returns(@events)
            
            get :index, :page_id => 1001
          end
          
          should_assign_to(:month){12}
          should_assign_to(:year){2012}
          should_assign_to(:events){@events}
          should_succeed_with :index
        end
      end
    end

    def should_allow_show
      context "getting show" do
        setup do
          get :show, :page_id => 1001, :id => 1002
        end
        
        should_assign_to(:event){@event}
        should_redirect_to("browse page"){browse_url(@page, 1, 2010)}
        should_not_set_the_flash
      end
    end
    
    def should_allow_new
      context "getting new" do
        setup do
          get :new, :page_id => 1001
        end
        
        should_assign_to :event, :class => Event
        should_succeed_with :new
      end
    end
    
    def should_allow_create
      context "posting create" do
        context "with valid data" do
          setup do 
            Event.any_instance.expects(:save).returns(true).once
            post :create, :page_id => 1001, :event => {}
          end
          
          should_assign_to :event, :class => Event
          should_redirect_to("events"){events_path(@page)}
          should_set_the_flash_to "Event was successfully created"
        end
        
        context "with invalid data" do
          setup do
            Event.any_instance.expects(:save).returns(false).once
            post :create, :page_id => 1001, :event => {}
          end
          
          should_assign_to :event, :class => Event
          should_succeed_with :new
        end
      end
    end    

    def should_allow_edit
      context "getting edit" do
        setup do
          get :edit, :page_id => 1001, :id => 1002
        end
        
        should_assign_to(:event){@event}
        should_succeed_with :edit
      end
    end
    
    def should_allow_update
      context "updating" do
        context "with valid data" do
          setup do
            @event.expects(:update_attributes).returns(true).once
            put :update, :page_id => 1001, :id => 1002, :event => {}
          end
          
          should_assign_to(:event){@event}
          should_redirect_to("events"){events_url(@page.id)}
          should_set_the_flash_to "Event was successfully updated"
        end
        
        context "with invalid data" do
          setup do
            @event.expects(:update_attributes).returns(false).once
            put :update, :page_id => 1001, :id => 1002, :event => {}
          end
          
          should_assign_to(:event){@event}
          should_succeed_with :edit
        end
      end
    end
    
    def should_allow_destroy
      context "destroying" do
        setup do
          @event.expects(:destroy).once
          delete :destroy, :page_id => 1001, :id => 1002
        end
        
        should_assign_to(:event){@event}
        should_redirect_to("events"){events_url(@page.id)}
        should_not_set_the_flash
      end
    end
    
    def actify(action)
      case action
        when :index   then 'get :index'
        when :show    then 'get :show'
        when :new     then 'get :new'
        when :create  then 'post :create'
        when :edit    then 'get :edit'
        when :update  then 'put :update'
        when :destroy then 'delete :destroy'
        else (action.is_a?(Symbol) ? "get :#{action}" : action)
      end
    end
    
    def should_deny(*actions)
      actions = [:index, :show, :new, :create, :edit, :update, :destroy] if actions == [:all]

      actions.each do |action|
        context "attempting get #{action}" do
          setup do
            eval actify(action)
          end
          
          should_not_assign_to :events
          should_not_assign_to :event
          should_redirect_to("root"){root_url}
          should_not_set_the_flash
        end
      end
    end
    
    def should_require_login_for(*actions)
      actions = [:index, :show, :new, :create, :edit, :update, :destroy] if actions == [:all]

      actions.each do |action|
        context "attempting to #{action}" do
          setup do
            eval actify(action)
          end
          
          should_not_assign_to :events
          should_not_assign_to :event
          should_redirect_to("login"){new_session_path}
          should_not_set_the_flash
        end
      end
    end
    
    def with_editable_and_viewable(*sets, &block)
      sets.each do |usable_by|
        editable_by, viewable_by = usable_by.split(/\//)
        viewable_by ||= editable_by
        
        context "when page is viewable by #{viewable_by} and editable by #{editable_by}" do
          setup do
            @page.viewable_by = viewable_by
            @page.editable_by = editable_by
          end
          
          merge_block &block
        end
      end
    end
  end
  
  def setup
    @page = Page.new(:name => 'Page')
    @page.id = 1001
    Page.stubs(:find).returns(@page)
    
    @event = Event.new(:name => 'Event', :all_day => true, :from_date => '2010-01-01', :to_date => '2010-01-01', :page_id => 1001)
    @event.id = 1002
    
    @events = [@event]
    Event.stubs(:find).returns(@event)
    Event.stubs(:find).with(:all, any_parameters).returns(@events)
  end
  
  context "as admin" do
    setup do
      login_as :admin
    end

    with_editable_and_viewable('all users/public', 'all users', 'admin/public', 'admin/all users', 'admin') do
      should_allow :all 
    end
  end
  
  context "as a member" do
    setup do
      login_as :quentin
    end
    
    with_editable_and_viewable('all users/public', 'all users') do
      should_allow :all    
    end
    
    with_editable_and_viewable('admin/public', 'admin/all users') do
      should_allow :index, :show, :create, :update, :destroy
      should_deny :new, :edit
    end
    
    with_editable_and_viewable('admin') do
      should_allow :show, :create, :update, :destroy
      should_deny :index, :new, :edit
    end
  end
  
  context "as a visitor" do
    with_editable_and_viewable('all users/public', 'admin/public') do
      should_allow :index, :show
      should_require_login_for :new, :create, :edit, :update, :destroy
    end
    
    with_editable_and_viewable('all users', 'admin', 'admin/all users') do
      should_allow :show
      should_deny  :index
      should_require_login_for :new, :create, :edit, :update, :destroy
    end
  end
end
