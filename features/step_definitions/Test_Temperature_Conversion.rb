require 'watir'
require 'cucumber'
require "test/unit/assertions"
require 'win32/screenshot' #gem install win32screenshot Doesn't work. need ruby64->32
include Test::Unit::Assertions
$browser = Watir::Browser.new :firefox
$browser.goto "file:///" + Dir.pwd + "/index.html"
at_exit do
  $browser.close
end
Given(/^I input a (?:valid|invalid) ihuanput '(.*)' in '(.*)'$/) do |temperatureNum, originalUnit|
  $browser.link(:text=>"Temperature").click
  $browser.text_field(:id => "fromValue").set "#{temperatureNum}"
  $browser.select(:id => "from").select "#{originalUnit}"
end
And("I choose '{word}' as the result unit") do |targetUnit|
  $browser.select(:id => "to").select "#{targetUnit}"
  $browser.button(:id => "submitButton").click
end
Then("I get a result of {string}") do |result|
  $browser.button(:id => "submitButton").click
  resultMessage = $browser.div(:class => "container").div(:id => "results").h2.text
  $browser.screenshot.save (".\\features\\Screenshoot\\" +  Time.now.strftime("%Y%m%dT%H%M%S%z") + ".png")
  assert((/((-)?\d+(\.\d+)?)/.match(resultMessage) and \
        /((-)?\d+(\.\d+)?)/.match(resultMessage)[0].eql? (result)),'The result is the same as expected!')
end
Then("I get a alert with a message of {string}") do |errorMessage|
  resultMessage = $browser.alert.text
  Win32::Screenshot::Take.of(:window, :title => /Convert/).write(".\\features\\Screenshoot\\" \
             +  Time.now.strftime("%Y%m%dT%H%M%S%z") + ".png")
  $browser.alert.ok
  assert(resultMessage.eql? (errorMessage))
end