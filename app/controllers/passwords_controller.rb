class PasswordsController < ApplicationController

  def new
    @password = Password.new
  end

  def create
    @password = Password.new(params[:password])
    @password.user = User.find_by_email(@password.email)
    
    if @password.save
      PasswordMailer.deliver_forgot_password(@password)
      flash[:notice] = "A link to change your password has been sent to #{@password.email}."
      redirect_to :action => :new
    else
      render :action => :new
    end
  end

  def reset
    @password = Password.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.now])
    @user = @password.user if @password
    
    unless @password && @user
      flash[:notice] = 'The change password URL you visited is either invalid or expired.'
      redirect_to new_password_path
    end      
  end

  def update_after_forgetting
    @user = Password.find_by_reset_code(params[:reset_code]).user
    
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Password was successfully updated.'
      redirect_to login_path
    else
      flash[:error] = 'EPIC FAIL!'
      redirect_to :action => :reset, :reset_code => params[:reset_code]
    end
  end
end
