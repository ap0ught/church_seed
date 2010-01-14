require 'test_helper'

class PasswordTest < ActiveSupport::TestCase
  should_belong_to :user
  
  should_validate_presence_of :email, :user
  
  context "validating email format as x@y.zz" do
    setup do
      @password = Password.new(:user_id => 1)
      @error = 'is not a valid email address'
    end
    
    should "succeed with the right format" do
      @password.email = 'john@smith.com'
      assert @password.valid?
      assert @password.errors.empty?
    end
    
    should "require username" do
      @password.email = '@smith.com'
      assert !@password.valid?
      assert_equal @error, @password.errors.on(:email)
    end
    
    should "require at symbol" do
      @password.email = 'johnsmith.com'
      assert !@password.valid?
      assert_equal @error, @password.errors.on(:email)
    end
    
    should "require subdomain" do
      @password.email = 'john@.com'
      assert !@password.valid?
      assert_equal @error, @password.errors.on(:email)
    end
    
    should "require alphanumeric/dashed subdomain" do
      @password.email = 'john@sm!th.com'
      assert !@password.valid?
      assert_equal @error, @password.errors.on(:email)
    end
    
    should "require dot" do
      @password.email = 'john@smithcom'
      assert !@password.valid?
      assert_equal @error, @password.errors.on(:email)
    end
    
    should "require top level domain" do
      @password.email = 'john@smith.'
      assert !@password.valid?
      assert_equal @error, @password.errors.on(:email)
    end
  end
  
  context "before create" do
    setup do
      @password = Password.new(:email => 'john@smith.com', :user_id => 1)
      Digest::SHA1.expects(:hexdigest).returns('0123456789abcdef0123456789abcdef')
      Password.connection.stubs(:insert).returns(true)
      
      @password.save
    end
    
    should "set the reset code" do
      assert_equal '0123456789abcdef0123456789abcdef', @password.reset_code
    end
    
    should "set the expiration date" do
      assert_equal 2.weeks.from_now.strftime('%Y-%m-%d'), @password.expiration_date.strftime('%Y-%m-%d')
    end
  end
end
