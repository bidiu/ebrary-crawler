require "selenium-webdriver"
require "json"
require "./cookie.rb"
require "./login.rb"
require "../config/config.rb"

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

driver = Selenium::WebDriver.for $browser
MyLogin.set_driver(driver)

# navigate to book detail page
MyLogin.to_book_detail
# save cookies
MyCookie.save_cookies driver.manage.all_cookies.each
# save docid
MyCookie.save_docid /\d+$/.match(driver.current_url)

# about to download
sleep sleep_duration
begin
	# TODO
	# driver.find_element(:id, "readerReadBtnId").click
rescue Selenium::WebDriver::Error::NoSuchElementError
	abort "Fail to download - the book is being used by other users."
ensure
	driver.quit
end
