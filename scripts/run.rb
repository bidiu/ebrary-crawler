#!/usr/bin/env ruby

require "selenium-webdriver"
require "json"
require "../config/config.rb"
require "./global.rb"
require "./cookie.rb"
require "./login.rb"
require "./downloader.rb"

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
	if not $page_height
		$page_height = driver.execute_script(
						"return document.getElementById(\"mainViewerImgCloakWrapper_#{page_no}\").style.height").to_i
		$view_height = driver.execute_script(
						"return document.getElementById(\"mainViewerPagesContainerWrapper\").style.height").to_i
	end
	# get the encrypted url
	url = img["src"]
	Downloader.instance.download(url, page_no)
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
			puts "Request timeouts, retry - #{t}/#{times}.."
		end
	end
end

# TODO common
# see wait_async_request
def async_element(selector_type, selector, driver, times: 1, timeout:)
	wait_async_request(times, timeout) do
		driver.find_elements(selector_type, selector).size > 0
	end
	driver.find_element(selector_type, selector)
end

def page_pos(page_no, page_height)
	page_no * (page_height + PAGE_POS_OFFSET)
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
	puts "Just logged in with following saved cookies: "
	driver.manage.all_cookies.each do |cookie|
		puts cookie.to_json
	end
end

# about to download
begin
	sleep sleep_duration
	driver.find_element(:id, "readerReadBtnId").click

	# start the downloading logic
	zoom_btn = async_element(:css, "button.icon-page-zoom-in", driver,
							 timeout: $request_timeout)
	$zoom_in.times { zoom_btn.click }
	page_info_span = async_element(:css, "#tool-pageloc .total-number-of-pages", driver,
								   timeout: $request_timeout)
	# TODO support breakpoint download
	page_no = 1
	while true
		sleep sleep_duration
		download_onepage(driver, page_no)
		# one page downloaded
		page_no += 1
		next_page_pos = page_pos(page_no, $page_height)
		break if next_page_pos >= $view_height
		# scroll to next page
		driver.execute_script("document.getElementById(\"mainViewer\").scrollTop = #{next_page_pos}")
	end
	puts "Data successfully downloaded into data folder."
rescue Selenium::WebDriver::Error::NoSuchElementError
	abort "Fail to download - probably the book's being used by others."
ensure
	driver.quit
end
