def should_require_login
  should_require_login_for :all
end

def should_require_login_for(*tests)
  model = test_unit_class.name.gsub(/ControllerTest$/, '').singularize.constantize
  
  tests = [:index, :show, :new, :create, :edit, :update, :destroy] if tests.include?(:all)
  
  tests.each do |test|
    action = case test
      when :index   then "get :index"
      when :show    then "get :show"
      when :new     then "get :new"
      when :create  then "post :create"
      when :edit    then "get :edit"
      when :update  then "put :update"
      when :destroy then "delete :destroy"
      else test
    end
  
    context "attempting to #{action}" do
      setup do
        eval action
      end
    
      should_not_assign_to model.name.to_sym
      should_redirect_to("login"){new_session_path}
      should_not_set_the_flash
    end
  end
end

def should_not_authorize(test)
  model = test_unit_class.class.name.gsub(/ControllerTest$/, '').singularize.constantize

  setup do
    eval test
  end
  
  should_not_assign_to model.name.to_sym
  should_respond_with 401
  should_render_without_layout
  should_not_set_the_flash
end
