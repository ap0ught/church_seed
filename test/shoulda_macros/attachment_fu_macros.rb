class Test::Unit::TestCase
  class << self
    def should_validate_as_attachment
      klass = self.name.gsub(/Test$/, '').constantize

      context "validate as attachment" do
        should_validate_presence_of :size, :content_type, :filename
      
        should "validate with :attachment_attributes_valid?" do
          callback_chain = klass.validate_callback_chain
          assert callback_chain.map(&:method).include?(:attachment_attributes_valid?)
        end
      end
    end

    def should_have_attachment(options = {})
      klass = self.name.gsub(/Test$/, '').constantize
      
      context "should have attachment options" do
        options.each do |key, val|
          should "have the correct options for key #{key}" do
            assert val, klass.attachment_options[key]
          end
        end
      end
    end
  end
end
