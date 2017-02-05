require "./cookie.rb"

class MyLogin

	@@driver = nil

	def self.set_driver(driver)
		@@driver ||= driver
	end

	# https://login.proxy.library.carleton.ca/login
	def self.login(driver = nil)
		set_driver(driver)
		form = @@driver.find_elements(:css, "form")[1]
		form.find_element(:name, "user").send_keys $user
		form.find_element(:name, "pass").send_keys $pwd
		form.find_element(:css, "input[type=\"submit\"]").click
	end

	def self.login_page?(driver = nil)
		set_driver(driver)
		@@driver.find_elements(:id, "pin-wrapper").size > 0
	end

	# navigate to book detail page (not book view page)
	def self.to_book_detail(driver = nil)
		set_driver(driver)
		if (cookies = MyCookie.load_cookies)
			# have cookies right now, although might already expired
			cookies.each do |cookie|
				@@driver.manage.add_cookie cookie
			end
			@@driver.navigate.to "#{$book_url}?docId=#{MyCookie.load_docid}"
			if login_page?
				sleep sleep_duration
				login
			end
		else
			# cookies not avaiable
			@@driver.navigate.to $host
			@@driver.find_element(:class, "summonbox").send_keys $book_title
			@@driver.find_element(:class, "summonsubmit").click
			switch_to_new_window @@driver
			# wait for asynchronous request completed
			begin
				wait = Selenium::WebDriver::Wait.new timeout: $request_timeout
				wait.until do
					@@driver.find_elements(:css, "div.inner>ul>li").size > 0
				end
			rescue Selenium::WebDriver::Error::TimeOutError
				abort "Request timeout - consider increasing the value of 'request_timeout'."
			end
			# at list page right now
			sleep sleep_duration
			@@driver.find_elements(:css, "div.inner>ul>li")[$result_no + 1]
				.find_elements(:css, "a")[0].click
			switch_to_new_window @@driver
			# login
			sleep sleep_duration
			login
		end
	end

end
