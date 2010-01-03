module Woulda
  module ActsAsList
    module Macros
      # Original source: http://www.soyunperdedor.com/node/34
      def should_act_as_list(options = {})
        configuration = {:column => :position}
        configuration.update(options) if options.is_a?(Hash)
        
        klass = self.name.gsub(/Test$/, '').constantize

        context "To support acts_as_list" do
          should_have_db_column(configuration[:column].to_s, :type => :integer)

          if configuration[:scope]
            if configuration[:scope].is_a?(Symbol)
              configuration[:scope] = configuration[:scope].to_s
              configuration[:scope] << '_id' unless configuration[:scope] =~ /_id$/

              should_have_db_column(configuration[:scope], :type => :integer)
              
              should "have the correct scope condition when key is nil" do
                obj = klass.new(configuration[:scope] => nil)
                assert_equal "#{configuration[:scope]} IS NULL", obj.scope_condition
              end
              
              should "have the correct scope condition when key has a value" do
                obj = klass.new(configuration[:scope] => 5)
                assert_equal "#{configuration[:scope]} = 5", obj.scope_condition
              end
            else
              should "have the correct scope condition" do
                obj = klass.new
                assert_equal configuration[:scope], obj.scope_condition
              end
            end
          end
        end

        should "include ActsAsList methods" do
          assert klass.include?(ActiveRecord::Acts::List::InstanceMethods)
        end

        should_have_instance_methods :acts_as_list_class, :position_column, :scope_condition
      end
    end
  end
end
