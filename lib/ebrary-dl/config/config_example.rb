module Ebrary
	module Dl
		# or :firefox
		BROWSER = :chrome
		# the url used to fresh login (without any saved session cookie)
		FRESH_LOGIN_URL = "https://library.carleton.ca/"
		# the login url of the proxy web site
		LOGIN_URL = "https://login.proxy.library.carleton.ca/login"
		# not incude parameters
		BOOK_URL = "http://site.ebrary.com.proxy.library.carleton.ca/lib/oculcarleton/detail.action"
		COOKIE_DOMAIN = ".library.carleton.ca"
		BOOK_TITLE = "Cryptography Engineering"
		RESULT_NO = 1
		# in second unit
		REQUEST_TIMEOUT = 16
		# maximal times of try for single page
		MAX_TRY = 8
		# imitate human, in second unit
		SUSPEND_MIN = 6
		# imitate human, in second unit
		SUSPEND_MAX = 10
		# zoomin factor
		ZOOM_IN = 2
		USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36"
		USER = "username"
		PWD = "password"
	end
end
