require 'shoulda'
require File.dirname(__FILE__) + '/acts_as_tree/macros'

Test::Unit::TestCase.class_eval do
  extend Woulda::ActsAsTree::Macros
end
