class Test::Unit::TestCase
  class << self
    def should_have_callback(callback, *methods)
      klass = self.name.gsub(/Test$/, '').constantize
      
      context "#{callback} callback chain" do
        methods.each do |method|
          should "contain #{method}" do
            callback_chain = klass.send("#{callback}_callback_chain")
            assert callback_chain.map(&:method).include?(method)
          end
        end
      end
    end

    alias_method :should_have_callbacks, :should_have_callback
  end
end
