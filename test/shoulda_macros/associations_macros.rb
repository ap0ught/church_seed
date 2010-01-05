class Test::Unit::TestCase
  def self.should_have_many(*associations)
    options = associations.last.is_a?(Hash) ? associations.pop : {}

    klass = self.name.gsub(/Test$/, '').constantize
    
    associations.each do |association|
      options.each do |key, val|
        should "have many #{association} and set the #{key} option" do
          assert_equal val, klass.reflections[association].options[key]
        end
      end
    end

    original_options = {}
    [:dependent, :through].each{|opt| original_options[opt] = options[opt] if options[opt] }
    associations << original_options
    super *associations
  end
  
  def self.should_belong_to(*associations)
    options = associations.last.is_a?(Hash) ? associations.pop : {}

    klass = self.name.gsub(/Test$/, '').constantize
    
    associations.each do |association|
      options.each do |key, val|
        should "belong_to #{association} and set the #{key} option" do
          assert_equal val, klass.reflections[association].options[key]
        end
      end
    end

    super *associations
  end
end
