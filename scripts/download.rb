require "selenium-webdriver"

def switch_to_new_window(driver)
	driver.switch_to.window driver.window_handles[-1]
end

load "config.rb"

driver = Selenium::WebDriver.for $browser
driver.navigate.to $host

driver.find_element(:class, "summonbox").send_keys $book_title
driver.find_element(:class, "summonsubmit").click
switch_to_new_window driver
# wait for asynchronous request completed
begin
	wait = Selenium::WebDriver::Wait.new timeout: $request_timeout
	wait.until do
		driver.find_elements(:css, "div.inner>ul>li").size > 0
	end
rescue Selenium::WebDriver::Error::TimeOutError
	abort "Request timeout - consider increasing the value of 'request_timeout'."
end

sleep $suspend
driver.find_elements(:css, "div.inner>ul>li")[$result_no + 1]
	.find_elements(:css, "a")[0].click
switch_to_new_window driver

# login
sleep $suspend
form = driver.find_elements(:css, "form")[1]
form.find_element(:name, "user").send_keys $user
form.find_element(:name, "pass").send_keys $pwd
form.find_element(:css, "input[type=\"submit\"]").click

# at the book detail page right now
sleep $suspend
begin
	driver.find_element(:id, "readerReadBtnId").click
rescue Selenium::WebDriver::Error::NoSuchElementError
	abort "Fail to download - the book is being used by other users."
end

puts "Successfully downloaded."
sleep $suspend
driver.quit
