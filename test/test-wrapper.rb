# -*- ruby -*-
#
# Copyright (C) 2012  Kouhei Sutou <kou@clear-code.com>
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

require "test-unit-capybara-test-utils"

class WrapperTest < Test::Unit::TestCase
  class WrappedTest < Test::Unit::TestCase
    include Capybara::DSL

    @@testing = false

    class << self
      def testing=(testing)
        @@testing = testing
      end
    end

    def valid?
      @@testing
    end

    setup do
      @html = <<-HTML
<html>
  <body>
    <h1>Hello</h1>
    <h2>Yay!</h2>
    <div class="section">
      <h2>World</h2>
    </div>
  </body>
</html>
HTML
      Capybara.app = lambda do |environment|
        [
          200,
          {"Content-Type" => "text/html"},
          [@html],
        ]
      end
    end

    def test_find_fail
      visit("/")
      within("div.section") do
        section_html = @html.scan(/<div class="section">.*?<\/div>/m)[0]
        h2_html = section_html.scan(/<h2>.*?<\/h2>/m)[0]
        message = <<-EOM.strip
<"h2">(:css) expected to not find a element but was
<#{PP.pp(h2_html, "").chomp}> in
<#{PP.pp(section_html, "").chomp}>
EOM
        exception = Test::Unit::AssertionFailedError.new(message)
        assert_raise(exception) do
          find("h3")
        end
      end
    end
  end

  def setup
    WrappedTest.testing = true
  end

  def teardown
    WrappedTest.testing = false
  end

  def test_find
    result = _run_test
    message = <<-EOM.chomp
<Test::Unit::AssertionFailedError(<<"h2">(:css) expected to not find a element but was
<"<h2>World</h2>"> in
<"<div class=\\"section\\">\\n      <h2>World</h2>\\n    </div>">>)> exception expected but was
<Test::Unit::Capybara::ElementNotFound(<Unable to find css "h3">)>.

diff:
+ Test::Unit::Capybara::ElementNotFound(<Unable to find css "h3">)
- Test::Unit::AssertionFailedError(<<"h2">(:css) expected to not find a element but was
- <"<h2>World</h2>"> in
- <"<div class=\\"section\\">\\n      <h2>World</h2>\\n    </div>">>)

folded diff:
+ Test::Unit::Capybara::ElementNotFound(<Unable to find css "h3">)
- Test::Unit::AssertionFailedError(<<"h2">(:css) expected to not find a element 
- but was
- <"<h2>World</h2>"> in
- <"<div class=\\"section\\">\\n      <h2>World</h2>\\n    </div>">>)
EOM
    assert_equal([message],
                 result.failures.collect {|failure| failure.message})
    assert_equal("1 tests, 1 assertions, 1 failures, 0 errors, 0 pendings, " \
                 "0 omissions, 0 notifications", result.to_s)
  end

  private
  def _run_test
    result = Test::Unit::TestResult.new
    test = WrappedTest.suite
    yield(test) if block_given?
    test.run(result) {}
    result
  end
end
