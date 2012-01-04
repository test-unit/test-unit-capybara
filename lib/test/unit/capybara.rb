# -*- ruby -*-
#
# Copyright (C) 2011-2012  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "test/unit/capybara/version"

require 'capybara'
require 'capybara/dsl'
require 'test/unit'

module Test::Unit
  module Capybara
    module Adapter
      class << self
        def included(mod)
          mod.module_eval do
            setup :before => :prepend
            def setup_capybara
              return unless self.class.include?(::Capybara::DSL)
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
