# News

## 1.1.0 - 2021-03-15

### Improvements

* Suppressed a keyword argument warning with Ruby 2.7 or later.

## 1.0.9 - 2019-07-11

### Fixes

* Fixed a bug that this doesn't work with `Rack::Test`.

## 1.0.8 - 2019-07-11

### Improvements

* Added support for Selenium element.

* Updated CI configurations.
  [GitHub#14][Patch by neko maho]

### Fixes

* Fixed documents.
  [GitHub#12][GitHub#13][Patch by Akira Matsuda]

### Thanks

* Akira Matsuda

## 1.0.7 - 2018-08-27

### Improvements

* Converted document format to Markdown.
  [GitHub#8][Patch by okkez]

* Added an example for JavaScript driver.
  [GitHub#4][GitHub#9][GitHub#10][Patch by okkez]

* Improved support for Capybara 3.
  [GitHub#11][Patch by neko maho]

### Thanks

  * okkez

  * neko maho

## 1.0.6 - 2018-06-06

### Improvements

* Improved release script.
  [GitHub#5] [Patch by Hiroyuki Sato]

* Updated documents.
  [GitHub#6] [Patch by Hiroyuki Sato]

* Added support for Capybara 3.
  [GitHub#7] [Patch by neko maho]

### Thanks

* Hiroyuki Sato

* Hiroyuki Sato

* neko maho

## 1.0.5 - 2016-01-18

### Improvements

* Stopped to register auto test runner.

## 1.0.4 - 2013-05-15

A Capybara 2.1.0 support release.

### Improvements

* Supported Capybara 2.1.0.
  It requires Capybara >= 2.1.0.
  Notice: Capybara < 2.1.0 aren't supported from this release.
  [GitHub#2] [Reported by thelastinuit]

### Thanks

* thelastinuit

## 1.0.3 - 2012-11-29

A support Capybara 2.0.1 release.

### Improvements

* Supported Capybara 2.0.1.
  It requires Capybara >= 2.0.1 and test-unit >= 2.5.3.
  Notice: Capybara 1.X aren't supported yet from this release.

## 1.0.2 - 2012-03-12

A Capybara integration improvement release.

### Improvements

  * Supported Capybara 1.1.2 again.

## 1.0.1 - 2012-01-16

A Capybara integration improvement release.

### Improvements

  * Added {Test::Unit::Capybara::Assertions#assert_all}.
  * Added {Test::Unit::Capybara::Assertions#assert_not_find}.
  * Supported Capybara::ElementNotFound as a failure.

## 1.0.0 - 2011-05-01

The first release!!!
