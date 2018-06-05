# -*- ruby -*-
#
# Copyright (C) 2011-2013  Kouhei Sutou <kou@clear-code.com>
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

require "capybara"
require "capybara/dsl"
require "json"
require "test-unit"
require "test/unit/assertions"

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

    # @private
    class ElementNotFound < ::Capybara::ElementNotFound
      attr_accessor :node
      attr_reader :kind, :locator
      def initialize(node, kind, locator, message)
        @node = node
        @kind = kind
        @locator = locator
        super(message)
      end
    end

    # @private
    module FindErrorWrapper
      def find(*args)
        begin
          super
        rescue ::Capybara::ElementNotFound => error
          if ::Capybara::VERSION >= "3.0.0.rc1"
            query = ::Capybara::Queries::SelectorQuery.new(*args, session_options: session_options)
          else
            query = ::Capybara::Query.new(*args)
          end
          new_error = ElementNotFound.new(self,
                                          query.selector.name,
                                          query.locator,
                                          error.message)
          raise new_error
        end
      end
    end

    # @private
    class ::Capybara::Node::Base
      include FindErrorWrapper
    end

    # @private
    module ElementNotFoundHandler
      class << self
        def included(base)
          base.exception_handler(:handle_capybara_element_not_found)
        end
      end

      private
      def handle_capybara_element_not_found(exception)
        return false unless exception.is_a?(ElementNotFound)
        return false unless respond_to?(:flunk_find)
        begin
          flunk_find(exception.node,
                     :kind => exception.kind,
                     :locator => exception.locator)
        rescue AssertionFailedError => assertion_failed_error
          assertion_failed_error.backtrace.replace(exception.backtrace)
          handle_exception(assertion_failed_error)
        end
      end
    end

    # @private
    class NodeInspector
      Inspector = ::Test::Unit::Assertions::AssertionMessage::Inspector
      Inspector.register_inspector_class(self)

      class << self
        def target?(object)
          object.is_a?(::Capybara::Node::Base)
        end

        def source(node)
          if node.base.respond_to?(:source)
            node.base.source
          else
            node.base.native.to_s
          end
        end
      end

      def initialize(node, inspected_objects)
        @node = node
        @inspected_objects = inspected_objects
      end

      def inspect
        @node.inspect.gsub(/>\z/, " #{self.class.source(@node)}>")
      end

      def pretty_print(q)
        q.text(@node.inspect.gsub(/>\z/, ""))
        q.breakable
        q.text("#{self.class.source(@node)}>")
      end
    end

    module Assertions
      # @private
      AssertionMessage = ::Test::Unit::Assertions::AssertionMessage

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
      #   assert_body({"status" => true}, :content_type => :json)
      #
      # @example Failure case
      #   # Actual response:
      #   #   Content-Type: text/html
      #   #   Body: <html><body>Hello</body></html>
      #   assert_body("<html><body>World</body></html>")
      def assert_body(expected, options={}, &block)
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

      # @param [...] args (see {::Capybara::Node::Finders#all})
      # @return [Array<::Capybara::Element>] The found elements.
      #
      # @see Capybara::Node::Finders#all
      #
      # @overload assert_all(*args)
      #   Passes if the selector finds one or more elements
      #   from the current node.
      #
      #   @example Pass case
      #     # Actual response:
      #     #   <html>
      #     #     <body>
      #     #       <h1>Hello</h1>
      #     #       <h2>Yay!</h2>
      #     #       <div class="section">
      #     #         <h2>World</h2>
      #     #       </div>
      #     #     </body>
      #     #   </html>
      #     h2_elements = assert_page_all("h2")
      #     p h2_elements
      #       # => [#<Capybara::Element tag="h2" path="/html/body/h2">,
      #       #     #<Capybara::Element tag="h2" path="/html/body/div/h2">]
      #
      #   @example Failure case
      #     # Actual response:
      #     #   <html>
      #     #     <body>
      #     #       <h1>Hello</h1>
      #     #       <h2>Yay!</h2>
      #     #       <div class="section">
      #     #         <h2>World</h2>
      #     #       </div>
      #     #     </body>
      #     #   </html>
      #     assert_page_all("h3")
      #
      # @overload assert_all(node, *args)
      #   Passes if the selector finds one or more elements
      #   from @node@.
      #
      #   @param [::Capybara::Node::Base] node The target node.
      #
      #   @example Pass case (simple)
      #     # Actual response:
      #     #   <html>
      #     #     <body>
      #     #       <h1>Hello</h1>
      #     #       <h2>Yay!</h2>
      #     #       <div class="section">
      #     #         <h2>World</h2>
      #     #       </div>
      #     #     </body>
      #     #   </html>
      #     section = assert_find("div.section")
      #     p section
      #       # => #<Capybara::Element tag="h2" path="/html/body/div">
      #     h2_elements = assert_all(section, "h2")
      #     p h2_elements
      #       # => [#<Capybara::Element tag="h2" path="/html/body/div/h2">]
      def assert_all(*args)
        node = nil
        node = args.shift if args[0].is_a?(::Capybara::Node::Base)
        args = normalize_page_finder_arguments(args)
        format = <<-EOT
<?>(?) expected to find one or more elements in
<?>
EOT
        current_context = node || page.send(:current_scope)
        current_context_source = node_source(current_context)
        source_in_message = AssertionMessage.literal(current_context_source)
        full_message = build_message(args[:message],
                                     format,
                                     args[:locator],
                                     args[:kind],
                                     source_in_message)
        if node
          elements = node.all(*args[:finder_arguments])
        else
          elements = all(*args[:finder_arguments])
        end
        assert_block(full_message) do
          not elements.empty?
        end
        elements
      end

      # @param [...] args (see {::Capybara::Node::Finders#find})
      #
      # @see ::Capybara::Node::Finders#find
      #
      # @overload assert_not_find(*args, &block)
      #   Passes if the selector doesn't find any elements
      #   from the current node.
      #
      #   @example Pass case
      #     # Actual response:
      #     #   <html>
      #     #     <body>
      #     #       <h1>Hello</h1>
      #     #       <h2>Yay!</h2>
      #     #       <div class="section">
      #     #         <h2>World</h2>
      #     #       </div>
      #     #     </body>
      #     #   </html>
      #     assert_not_find("h3")
      #
      #   @example Failure case
      #     # Actual response:
      #     #   <html>
      #     #     <body>
      #     #       <h1>Hello</h1>
      #     #       <h2>Yay!</h2>
      #     #       <div class="section">
      #     #         <h2>World</h2>
      #     #       </div>
      #     #     </body>
      #     #   </html>
      #     assert_not_find("h1")
      #
      # @overload assert_not_find(node, *args, &block)
      #   Passes if the selector doesn't find any element from @node@.
      #
      #   @param [::Capybara::Node::Base] node The target node.
      #
      #   @example Pass case
      #     # Actual response:
      #     #   <html>
      #     #     <body>
      #     #       <h1>Hello</h1>
      #     #       <h2>Yay!</h2>
      #     #       <div class="section">
      #     #         <h2>World</h2>
      #     #       </div>
      #     #     </body>
      #     #   </html>
      #     section = find("section")
      #     p section
      #       # => #<Capybara::Element tag="h2" path="/html/body/div">
      #     assert_not_find(section, "h1")
      #
      #   @example Failure case
      #     # Actual response:
      #     #   <html>
      #     #     <body>
      #     #       <h1>Hello</h1>
      #     #       <h2>Yay!</h2>
      #     #       <div class="section">
      #     #         <h2>World</h2>
      #     #       </div>
      #     #     </body>
      #     #   </html>
      #     section = find("section")
      #     p section
      #       # => #<Capybara::Element tag="h2" path="/html/body/div">
      #     assert_not_find(section, "h2")
      def assert_not_find(*args, &block)
        node = nil
        node = args.shift if args[0].is_a?(::Capybara::Node::Base)
        args = normalize_page_finder_arguments(args)
        if node
          element = node.first(*args[:finder_arguments])
        else
          element = first(*args[:finder_arguments])
        end
        format = <<-EOT
<?>(?) expected to not find a element but was
<?> in
<?>
EOT
        element_source = nil
        element_source = node_source(element) if element
        current_context = node || page.send(:current_scope)
        current_context_source = node_source(current_context)
        source_in_message = AssertionMessage.literal(current_context_source)
        full_message = build_message(args[:message],
                                     format,
                                     args[:locator],
                                     args[:kind],
                                     AssertionMessage.literal(element_source),
                                     source_in_message)
        assert_block(full_message) do
          element.nil?
        end
      end

      # Fails always with {::Capybara::Node::Element} is not
      # found message.
      #
      # @param [::Capybara::Node::Element] base_node The
      #   node used as search target.
      # @option options [String] :message The user custom
      #   message added to failure message.
      # @option options [String] :locator The query used to
      #   find a node.
      #
      #   It should be specified for useful failure message.
      # @option options [String] :kind The kind of query.
      #
      #   It should be specified for useful failure message.
      def flunk_find(base_node, options={})
        format = <<-EOT
<?>(?) expected to find a element in
<?>
EOT
        base_html = AssertionMessage.literal(node_source(base_node))
        full_message = build_message(options[:message],
                                     format,
                                     options[:locator],
                                     options[:kind],
                                     base_html)
        assert_block(full_message) do
          false
        end
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

      def node_source(node)
        if node
          if node.base.respond_to?(:source)
            node.base.source
          elsif node.base.respond_to?(:html)
            node.base.html
          else
            node.base.native.to_s
          end
        else
          source
        end
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
    include Capybara::ElementNotFoundHandler
  end
end
