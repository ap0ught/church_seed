def should_act_as_indexed(options={})

  klass = self.name.gsub(/Test$/, '').constantize
  
  if options[:fields]
    should "set the fields" do
      @index = stub(:save => true)
      @index.stubs(:add_record).returns(true)
      
      Foo::Acts::Indexed::SearchIndex.expects(:new).with(anything, anything, options[:fields], anything).returns(@index).once
      klass.index_add(klass.new)
    end
  end
    
  should "include ActsAsIndexed methods" do
    assert klass.include?(Foo::Acts::Indexed::InstanceMethods)
  end
end
