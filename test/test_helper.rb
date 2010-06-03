$:.unshift(File.join(File.dirname(__FILE__), '/../lib'))
ENV["RAILS_ENV"] = "test"
PLUGIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'test/unit'
require 'rubygems'
require 'rubygems'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'active_support/test_case'
require 'active_record/test_case'
require 'active_record/fixtures'
require File.join(PLUGIN_ROOT, 'init')

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.configurations = {'test' => {:adapter => "sqlite3", :dbfile => ":memory:"}}
ActiveRecord::Base.establish_connection(:test)

load(File.dirname(__FILE__) + "/schema.rb")

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = File.join(File.dirname(__FILE__), "/fixtures/")
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true

  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names)
    end
  end
end

$LOAD_PATH.unshift(ActiveSupport::TestCase.fixture_path)

class NonParanoidAndroid < ActiveRecord::Base
end

class Widget < ActiveRecord::Base
  acts_as_paranoid
  has_many :categories, :dependent => :destroy
  has_and_belongs_to_many :habtm_categories, :class_name => 'Category'
  has_one :category
  belongs_to :parent_category, :class_name => 'Category'
  has_many :taggings
  has_many :tags, :through => :taggings
  has_many :any_tags, :through => :taggings, :class_name => 'Tag', :source => :tag, :with_deleted => true
end

class Category < ActiveRecord::Base
  belongs_to :widget
  belongs_to :any_widget, :class_name => 'Widget', :foreign_key => 'widget_id', :with_deleted => true
  acts_as_paranoid

  def self.search(name, options = {})
    find :all, options.merge(:conditions => ['LOWER(title) LIKE ?', "%#{name.to_s.downcase}%"])
  end

  def self.search_with_deleted(name, options = {})
    find_with_deleted :all, options.merge(:conditions => ['LOWER(title) LIKE ?', "%#{name.to_s.downcase}%"])
  end
end

class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :widgets, :through => :taggings
end

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :widget
  acts_as_paranoid
end

class Array
  def ids
    collect &:id
  end
end
