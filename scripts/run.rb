#!/usr/bin/env ruby

require "selenium-webdriver"
require "json"
require "./cookie.rb"
require "./login.rb"
require "../config/config.rb"

# downloader bootstrap file

def switch_to_new_window(driver)
	driver.switch_to.window driver.window_handles[-1]
end

def sleep_duration
	real = rand * ($suspend_max - $suspend_min + 1) + $suspend_min
	real.to_i
end

def download_onepage(driver, page_no)
	img = async_element(:css, "#mainViewerImgCloakWrapper_#{page_no} img", driver, 
						times: $max_try, timeout: $request_timeout)
	puts img["src"]	
end

# times - max retry times
# timeout - timeout for async request
# code block - event to wait
def wait_async_request(times, timeout)
	raise ArgumentError, "'times' and 'timeout' have to be >= 1" if times < 1 or timeout < 1

	1.upto(times) do |t|
		begin
			wait = Selenium::WebDriver::Wait.new timeout: timeout
			wait.until { yield }
			break
		rescue Selenium::WebDriver::Error::TimeOutError
			abort "Request timeout - consider increasing the value of 'request_timeout'." if t >= times
		end
	end
end

# TODO common
# see wait_async_request
def async_element(selector_type, selector, driver, times:, timeout:)
	wait_async_request(times, timeout) do
		driver.find_elements(selector_type, selector).size > 0
	end
	driver.find_element(selector_type, selector)
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
	driver.find_element(:id, "readerReadBtnId").click

	# start the downloading logic
	page_info_span = async_element(:css, "#tool-pageloc .total-number-of-pages", driver, 
								   times: 1, timeout: $request_timeout)
	total_page_no = /\d+$/.match(page_info_span.text).to_s.to_i
	# TODO support breakpoint download
	1.upto(total_page_no) do |page_no|
		download_onepage(driver, page_no)
	end
rescue Selenium::WebDriver::Error::NoSuchElementError
	abort "Fail to download - probably the book's being used by others."
ensure
	driver.quit
end
