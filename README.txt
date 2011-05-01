= Test::Unit::Capybara

* http://rubyforge.org/projects/test-unit/

== DESCRIPTION:

test-unit-capybara - Capybara adapter for Test::Unit.

== FEATURES/PROBLEMS:

* This provides Capybara integrated Test::Unit::TestCase.

== INSTALL:

* sudo gem install test-unit-capybara

== USAGE:

  require 'test/unit/capybara'

  class TestMyRackApplication < Test::Unit::TestCase
    include Capybara

    def setup
      Capybara.app = MyRackApplication.new
    end

    def test_top_page
      visit("/")
      assert_equal("Welcome!", find("title").text)
    end
  end

== LICENSE:

LGPLv2.1 or later.

(Kouhei Sutou has a right to change the license including
contributed patches.)

== AUTHORS:

* Kouhei Sutou
