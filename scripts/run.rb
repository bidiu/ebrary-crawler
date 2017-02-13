#!/usr/bin/env ruby

require "selenium-webdriver"
require "json"
require_relative "../config/config"
require_relative "global"
require_relative "cookie"
require_relative "login"
require_relative "downloader"

# downloader bootstrap file

def switch_to_new_window(driver)
	driver.switch_to.window driver.window_handles[-1]
end

def sleep_duration
	real = rand * (SUSPEND_MAX - SUSPEND_MIN + 1) + SUSPEND_MIN
	real.to_i
end

def download_onepage(driver, page_no)
	img = async_element(:css, "#mainViewerImgCloakWrapper_#{page_no} img", driver,
						times: MAX_TRY, timeout: REQUEST_TIMEOUT)
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
	raise ArgumentError, "'page_no' can not be less than 1" if page_no < 1
	(page_no - 1) * (page_height + PAGE_POS_OFFSET)
end

# validate configuration
if SUSPEND_MIN > SUSPEND_MAX
	abort "'suspend_min' must be less than or equal to 'suspend_max'."
end


MyLogin.set_driver(driver = Selenium::WebDriver.for(BROWSER))

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
	zoom_btn = async_element(:css, "button.icon-page-zoom-in", driver,
							 timeout: REQUEST_TIMEOUT)
	ZOOM_IN.times { zoom_btn.click }
	$view_doc_url = driver.current_url
	Downloader.instance.detect_view_page_height driver

	page_no = Downloader.instance.last_downloaded_page_no
	puts "Resume downloading at page \##{page_no}." if page_no != 1
	while true
		cur_page_pos = page_pos(page_no, $page_height)
		break if cur_page_pos >= $view_height
		# scroll to current page position
		driver.execute_script("document.getElementById(\"mainViewer\").scrollTop = #{cur_page_pos}")
		sleep sleep_duration
		download_onepage(driver, page_no)
		puts "Page \##{page_no} downloaded."
		page_no += 1
	end
	puts "Data successfully downloaded into data folder."
rescue Selenium::WebDriver::Error::NoSuchElementError
	abort "Fail to download - probably the book's being used by others."
ensure
	driver.quit
end
