require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  class << self
    def should_allow_all_actions_as(type, user=nil)
      context "as #{type}" do
        setup do
          login_as user unless user.nil?
        end
        
        context "getting new" do
          setup do
            get :new
          end
          
          should_assign_to :password, :class => Password
          should_respond_with :success
          should_render_with_layout
          should_render_template :new
          should_not_set_the_flash
        end
        
        context "posting create" do
          setup do
            @user = User.new
            User.expects(:find_by_email).with('bob@smith.com').returns(@user)
          end
          
          context "with valid data" do
            setup do
              Password.any_instance.expects(:save).returns(true).once
              PasswordMailer.expects(:deliver_forgot_password).with(instance_of(Password)).once
              post :create, :password => {:email => 'bob@smith.com'}
            end
            
            should_assign_to :password, :class => Password
            should_redirect_to("new password"){new_password_path}
            should_set_the_flash_to "A link to change your password has been sent to bob@smith.com."
          end
          
          context "with invalid data" do
            setup do
              Password.any_instance.expects(:save).returns(false).once
              post :create, :password => {:email => 'bob@smith.com'}
            end
            
            should_assign_to :password, :class => Password
            should_respond_with :success
            should_render_with_layout
            should_render_template :new
            should_not_set_the_flash
          end
        end
        
        context "getting reset" do
          context "if current password record found" do
            setup do
              @password = Password.new
              Password.expects(:find).returns(@password).once
            end
            
            context "and it has a valid user" do
              setup do
                @user = User.new
                @password.expects(:user).returns(@user).once
                get :reset, :reset_code => 'abc'
              end
              
              should_assign_to(:password){@password}
              should_assign_to(:user){@user}
              should_respond_with :success
              should_render_with_layout
              should_render_template :reset
              should_not_set_the_flash
            end
            
            context "and it doesn't have a valid user" do
              setup do
                @password.expects(:user).returns(nil).once
                get :reset, :reset_code => 'abc'
              end
              
              should_assign_to(:password){@password}
              should_not_assign_to :user
              should_redirect_to("new password"){new_password_path}
              should_set_the_flash_to 'The change password URL you visited is either invalid or expired.'
            end
          end
          
          context "if current password record not found" do
            setup do
              Password.expects(:find).returns(nil).once
              get :reset, :reset_code => 'abc'
            end
            
            should_not_assign_to :password
            should_redirect_to("new password"){new_password_path}
            should_set_the_flash_to 'The change password URL you visited is either invalid or expired.'
          end
        end
        
        context "putting update_after_forgetting" do
          setup do
            @user = User.new
            
            @password = Password.new
            @password.expects(:user).returns(@user).once
            
            Password.expects(:find_by_reset_code).with('abc').returns(@password).once
          end
          
          context "with valid data" do
            setup do
              @user.expects(:update_attributes).with(has_entries('password' => 'newpass', 'password_confirmation' => 'newpass')).returns(true).once
              put :update_after_forgetting, :reset_code => 'abc', :user => {:password => 'newpass', :password_confirmation => 'newpass'}
            end
            
            should_assign_to(:user){@user}
            should_redirect_to("login"){login_path}
            should_set_the_flash_to 'Password was successfully updated.'
          end
          
          context "with invalid data" do
            setup do
              @user.expects(:update_attributes).with(has_entries('password' => 'newpass', 'password_confirmation' => 'newpass')).returns(false).once
              put :update_after_forgetting, :reset_code => 'abc', :user => {:password => 'newpass', :password_confirmation => 'newpass'}
            end
            
            should_assign_to(:user){@user}
            should_redirect_to("change password"){change_password_path(:reset_code => 'abc')}
            should_set_the_flash_to 'EPIC FAIL!'
          end
        end
      end
    end
  end
  
  should_allow_all_actions_as('admin', :admin)
  should_allow_all_actions_as('member', :quentin)
  should_allow_all_actions_as('visitor')
end
