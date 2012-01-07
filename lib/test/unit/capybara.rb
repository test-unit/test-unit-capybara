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
require "json"
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
              return unless self.class.include?(::Capybara::DSL)
              ::Capybara.reset_sessions!
              ::Capybara.use_default_driver
            end
          end
        end
      end
    end

    module Assertions
      # @see #assert_page_body
      # @deprecated since 1.0.0. Use {#assert_page_body} instead.
      def assert_body(expected, options={}, &block)
        warn(["deprecated. use assert_page_body instead.",
              *caller].join("\n"))
        assert_page_body(*args, &block)
      end

      # Passes if @expected@ == @source@. @source@ is a
      # method provided by Capybara::DSL.
      #
      # @source@ may be parsed depended on response
      # Content-Type before comparing. Here are parsed
      # Content-Types:
      #
      # - @"application/json"@ := It's parsed by @JSON.parse@.
      #
      # @param [Object] expected the expected body
      #   content. The actual body may be parsed. It
      #   depends on @:content_type@ option.
      #
      # @option options [String] :content_type (nil)
      #   the expected Content-Type. If this value is @nil@,
      #   Content-Type will not be compared.
      #
      #   This value can be specified by abbreviated. Here
      #   are abbreviations:
      #
      #   - @:json@ := @"application/json"@
      #
      # @yield [expected_response, actual_response] the
      #   optional compared responses normalizer.
      # @yieldparam [Hash] expected_response the expected
      #   response constructed in the method.
      # @yieldparam [Hash] actual_response the actual
      #   response constructed in the method.
      # @yieldreturn [expected_response, actual_response] the
      #   normalized compared responses.
      #
      # @example Pass case
      #   # Actual response:
      #   #   Content-Type: application/json
      #   #   Body: {"status": true}
      #   assert_page_body({"status" => true}, :content_type => :json)
      #
      # @example Failure case
      #   # Actual response:
      #   #   Content-Type: text/html
      #   #   Body: <html><body>Hello</body></html>
      #   assert_page_body("<html><body>World</body></html>")
      def assert_page_body(expected, options={}, &block)
        content_type = options[:content_type]
        actual_response = {
          :content_type => page_content_type,
          :body => parsed_page_body,
        }
        expected_response = {:body => expected}
        if content_type
          expected_response[:content_type] = normalize_content_type(content_type)
        else
          actual_response.delete(:content_type)
        end
        if block_given?
          expected_response, actual_response = yield(expected_response,
                                                     actual_response)
	end
        assert_equal(expected_response, actual_response)
      end

      # Passes if the selector finds one or more elements.
      # Arguments are the same as {Capybara::Node::Finders#all}.
      #
      # @return [Capybara::Element] the found elements.
      #
      # @see Capybara::Node::Finders#all
      #
      # @example Pass case
      #   # Actual response:
      #   #   <html>
      #   #     <body>
      #   #       <h1>Hello</h1>
      #   #       <h2>World</h2>
      #   #       <h2>Yay!</h2>
      #   #     </body>
      #   #   </html>
      #   h2_elements = assert_page_all("h2")
      #   p h2_elements
      #     # => [#<Capybara::Element tag="h2" path="/html/body/h2[1]">,
      #     #     #<Capybara::Element tag="h2" path="/html/body/h2[2]">]
      #
      # @example Failure case
      #   # Actual response:
      #   #   <html>
      #   #     <body>
      #   #       <h1>Hello</h1>
      #   #       <h2>World</h2>
      #   #       <h2>Yay!</h2>
      #   #     </body>
      #   #   </html>
      #   assert_page_all("h3")
      def assert_page_all(*args)
        args = normalize_page_finder_arguments(args)
        format = <<-EOT
<?>(?) expected to be match one or more elements in
<?>
EOT
        full_message = build_message(args[:message],
                                     format,
                                     args[:locator],
                                     args[:kind],
                                     source)
        elements = page.all(*args[:finder_arguments])
        assert_block(full_message) do
          not elements.empty?
        end
        elements
      end

      # Passes if the selector finds a element.
      # Arguments are the same as {Capybara::Node::Finders#find}.
      #
      # @return [Capybara::Element] the found element.
      #
      # @see Capybara::Node::Finders#find
      #
      # @example Pass case
      #   # Actual response:
      #   #   <html>
      #   #     <body>
      #   #       <h1>Hello</h1>
      #   #       <h2>World</h2>
      #   #       <h2>Yay!</h2>
      #   #     </body>
      #   #   </html>
      #   h2_element = assert_page_find("h2")
      #   p h2_element
      #     # => [#<Capybara::Element tag="h2" path="/html/body/h2[1]">]
      #
      # @example Failure case
      #   # Actual response:
      #   #   <html>
      #   #     <body>
      #   #       <h1>Hello</h1>
      #   #       <h2>World</h2>
      #   #       <h2>Yay!</h2>
      #   #     </body>
      #   #   </html>
      #   assert_page_find("h3")
      def assert_page_find(*args)
        args = normalize_page_finder_arguments(args)
        format = <<-EOT
<?>(?) expected to be match a element in
<?>
EOT
        full_message = build_message(args[:message],
                                     format,
                                     args[:locator],
                                     args[:kind],
                                     source)
        element = page.first(*args[:finder_arguments])
        assert_block(full_message) do
          not element.nil?
        end
        element
      end

      private
      def page_content_type
        page.response_headers["Content-Type"]
      end

      def parsed_page_body
        case page_content_type
        when "application/json"
          ::JSON.parse(source)
        else
          source
        end
      end

      def normalize_page_finder_arguments(args)
        args = args.dup
        options = {}
        options = args.pop if args.last.is_a?(Hash)
        if args.size == 1
          locator = args[0]
          if locator[0, 1] == "/"
            kind = :xpath
            args.unshift(kind)
          else
            kind = ::Capybara.default_selector
          end
        else
          kind, locator, = args
        end
        args << options

        {
          :kind => kind,
          :locator => locator,
          :message => options.delete(:message),
          :finder_arguments => args,
        }
      end

      # @private
      CONTENT_TYPE_SHORTCUTS = {
        :json => "application/json",
      }
      def normalize_content_type(content_type)
        CONTENT_TYPE_SHORTCUTS[content_type] || content_type
      end
    end
  end

  class TestCase
    include Capybara::Adapter
  end
end
