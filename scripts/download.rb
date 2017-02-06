#!/usr/bin/env ruby

require "selenium-webdriver"
require "json"
require "./cookie.rb"
require "./login.rb"
require "../config/config.rb"

#
# downloader bootstrap file
#

def switch_to_new_window(driver)
	driver.switch_to.window driver.window_handles[-1]
end

def sleep_duration
	real = rand * ($suspend_max - $suspend_min + 1) + $suspend_min
	real.to_i
end

# validate configuration
if $suspend_min > $suspend_max
	abort "'suspend_min' must be less than or equal to 'suspend_max'."
end


MyLogin.set_driver(driver = Selenium::WebDriver.for($browser))

# navigate to book detail page
if MyLogin.to_book_detail
	# save cookies & docid
	MyCookie.save_cookies driver.manage.all_cookies.each
	MyCookie.save_docid(/\d+$/.match(driver.current_url))
else
	puts "Just tried to login with following saved cookies: "
	driver.manage.all_cookies.each do |cookie|
		puts cookie.to_json
	end
end

# about to download
begin
	sleep sleep_duration
	# TODO
	# driver.find_element(:id, "readerReadBtnId").click
rescue Selenium::WebDriver::Error::NoSuchElementError
	abort "Fail to download - the book is being used by other users."
ensure
	driver.quit
end
