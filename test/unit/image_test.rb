require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  should_belong_to :article
  
  should_have_named_scope :originals, :conditions => ["parent_id IS NULL"]
  
  should_have_attachment   :content_type => :image,
                   :path_prefix  => 'public/imageupload',
                   :processor => 'rmagick',
                   :storage => :file_system, 
                   :max_size => 1024.kilobytes, # 1MB
                   :resize_to => '500x500>',
                   :thumbnails => { :thumb100 => '100x100>', 
                                    :thumb200 => '200x200>', 
                                    :thumb300 => '300x300>',
                                    :thumb400 => '400x400>' }
                                    
  should_validate_as_attachment
  
  context "finding thumbnail" do
    setup do
      @parent = Image.new
      @parent.id = 1001
      
      @image = Image.create(:parent_id => 1001, :thumbnail => 'thumb100', :width => 100, :height => 100, :size => 100, :filename => 'test.jpg', :content_type => 'image/jpg')
    end
    
    should "find the thumbnail if specified" do
      assert_equal '100x100', @parent.thumbnail_size('thumb100')
    end
    
    should "not find the thumbnail if not specified" do
      assert_nil @parent.thumbnail_size(nil)
    end
  end
end
