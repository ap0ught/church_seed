require File.dirname(__FILE__) + '/../test_helper'

class RoutingTest < ActiveSupport::TestCase
  should_map_resources :users, :except => [:new, :create]
  should_map_resources :passwords, :except => :new
  should_map_resources :roles
  should_map_resources :images
  should_map_resources :documents

  should_map_resources :comments, :collection => { :destroy_multiple => :delete},
                :member => { :approve => :put, :reject => :put }

  should_map_resources :pages
  should_map_nested_resources :pages, :components, :name_prefix => nil
  should_map_nested_resources :pages, :articles, :name_prefix => nil, :as => "content"
  should_map_nested_resources :pages, :newsitems, :name_prefix => nil, :as => "latest", :collection => {:archive => :get}
  should_map_nested_resources :pages, :posts, :name_prefix => nil, :as => "posts", :collection => {:archive => :get}
  should_map_nested_resources :pages, :events, :name_prefix => nil, :as => "list"
end
