def should_have_many_more(association, options={})

  klass = self.name.gsub(/Test$/, '').constantize
  
  if options[:dependent]
    should_have_many association, :dependent => options[:dependent]
  else
    should_have_many association
  end
  
  options.each do |key, val|
    should "have many #{association} and set the #{key} option" do
      assert_equal val, klass.reflections[association].options[key]
    end
  end
end
