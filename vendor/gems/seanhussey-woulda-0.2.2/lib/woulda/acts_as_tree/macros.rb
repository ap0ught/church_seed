module Woulda
  module ActsAsTree
    module Macros
      def should_act_as_tree(options = {})
        configuration = {:foreign_key => 'parent_id', :order => nil, :counter_cache => nil}
        configuration.update(options) if options.is_a?(Hash)
        
        klass = self.name.gsub(/Test$/, '').constantize

        context "To support acts_as_tree" do
          should_belong_to :parent
          should_have_db_column configuration[:foreign_key].to_s, :type => :integer
          
          if configuration[:counter_cache]
            if configuration[:counter_cache] == true
              should_have_db_column configuration[:counter_cache].to_s.demodulize.underscore.pluralize + '_count', :type => :integer
            else
              should_have_db_column configuration[:counter_cache], :type => :integer            
            end
          end
          
          should_have_many :children, :dependent => :destroy
          if configuration[:order]
            should "preserve the child order" do
              assert_equal configuration[:order], klass.reflections[:children].options[:order]
            end
          end
        end

        should "include ActsAsTree methods" do
          assert klass.include?(ActiveRecord::Acts::Tree::InstanceMethods)
        end

        should_have_class_methods :roots, :root
      end
    end
  end
end
