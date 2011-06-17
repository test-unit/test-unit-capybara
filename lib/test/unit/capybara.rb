#--
#
# Author:: Kouhei Sutou
# Copyright::
#   * Copyright (c) 2011 Kouhei Sutou <kou@clear-code.com>
# License:: LGPLv2+

require 'capybara'
require 'capybara/dsl'
require 'test/unit'

module Test::Unit
  module Capybara
    VERSION = "1.0.1"

    module Adapter
      class << self
        def included(mod)
          mod.module_eval do
            setup :before => :prepend
            def setup_capybara
              return unless self.class.include?(::Capybara)
              extend(Assertions)
              if self[:js]
                ::Capybara.current_driver = ::Capybara.javascript_driver
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

    module Assertions
      def assert_body(expected, options={})
        content_type = options[:content_type]
        case content_type
        when :json
          assert_equal({
                         :content_type => "application/json",
                         :body => expected,
                       },
                       {
                         :content_type => page.response_headers["Content-Type"],
                         :body => JSON.parse(source),
                       })
        else
          format = "unsupported content type: <?>\n" +
            "expected: <?>\n" +
            " options: <?>"
          arguments = [content_type, expected, options]
          assert_block(build_message(nil, format, *arguments)) do
            false
          end
        end
      end
    end
  end

  class TestCase
    include Capybara::Adapter
  end
end
