require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  should_belong_to :component, :article
  
  should_validate_presence_of :name
  should_validate_as_attachment

  should_have_attachment  :max_size => 20.megabytes,
                          :content_type => [
                            'application/pdf', 
                            'application/msword', 
                            'application/msexcel', 
                            'application/vnd.ms-excel',
                            'application/vnd.ms-powerpoint',
                            'application/octet-stream',
                            'text/rtf',
                            'text/plain',
                            'video/mpeg',
                            'video/quicktime',
                            'video/x-msvideo',
                            'audio/x-wav',
                            'audio/mpeg'
                          ],
                          :storage => :file_system
  
  context "ORDER_OPTIONS" do
    should "include Created Descending" do
      assert Document::ORDER_OPTIONS.include?(['Created Descending', 'created_at DESC'])
    end
    
    should "include Created Ascending" do
      assert Document::ORDER_OPTIONS.include?(['Created Ascending', 'created_at ASC'])
    end
    
    should "include Name Descending" do
      assert Document::ORDER_OPTIONS.include?(['Name Descending', 'name DESC'])
    end
    
    should "include Name Ascending" do
      assert Document::ORDER_OPTIONS.include?(['Name Ascending', 'name ASC'])
    end
    
    should "have four options" do
      assert_equal 4, Document::ORDER_OPTIONS.size
    end
  end
end
