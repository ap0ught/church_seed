class Test::Unit::TestCase
  def self.should_have_named_scope(scope_call, *args)
    klass = described_type
    scope_opts = args.extract_options!
    scope_call = scope_call.to_s
 
    context scope_call do
      setup do
        @scope = eval("#{klass}.#{scope_call}")
      end
 
      should "return a scope object" do
        assert_equal ::ActiveRecord::NamedScope::Scope, @scope.class
      end
 
      unless scope_opts.empty?
        should "scope itself to #{scope_opts.inspect}" do
          assert_equal scope_opts, @scope.proxy_options
        end
      end
    end
  end
end
