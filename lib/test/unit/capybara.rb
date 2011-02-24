#--
#
# Author:: Kouhei Sutou
# Copyright::
#   * Copyright (c) 2011 Kouhei Sutou <kou@clear-code.com>
# License:: Ruby license.

require 'capybara'
require 'capybara/dsl'
require 'test/unit'

module Test::Unit
  module Capybara
    VERSION = "1.0.0"

    module Adapter
      class << self
        def included(mod)
          mod.module_eval do
            setup :before => :prepend
            def setup_capybara
              return unless self.class.include?(::Capybara)
              if self[:js]
                ::Capybara.current_driver =  ::Capybara.javascript_driver
              end
              driver = self[:driver]
              ::Capybara.current_driver = driver if driver
            end

            teardown :after => :append
            def teardown_capybara
              return unless self.class.include?(::Capybara)
              ::Capybara.reset_sessions!
              ::Capybara.use_default_driver
            end
          end
        end
      end
    end
  end

  class TestCase
    include Capybara::Adapter
  end
end
