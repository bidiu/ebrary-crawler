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
	# return: whether fresh login
	def self.to_book_detail(driver = nil)
		set_driver(driver)
		fresh_login = nil
		if (cookies = MyCookie.load_cookies)
			# have cookies right now, although might already expired
			@@driver.navigate.to $login_url
			@@driver.manage.delete_all_cookies
			cookies.each do |cookie|
				if cookie = process_cookie(cookie)
					@@driver.manage.add_cookie cookie
				end
			end
			sleep sleep_duration
			@@driver.navigate.to "#{$book_url}?docID=#{MyCookie.load_docid}"
			if login_page?
				# cookies expired
				fresh_login = true
				sleep sleep_duration
				login
			else
				fresh_login = false
			end
		else
			# no saved session cookies
			fresh_login = true
			@@driver.navigate.to $fresh_login_url
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
		return fresh_login
	end

	# if not valid cookie, then return nil
	def self.process_cookie(cookie)
		cookie[:domain] = $cookie_domain unless $cookie_domain.include? cookie[:domain]
		cookie[:expires] = nil if cookie[:expires]
		cookie
	end
end
