require "selenium-webdriver"
require "http"
require "json"
require "uri"
require "cgi"
require "singleton"

require_relative "ebrary-dl/config/config"
require_relative "ebrary-dl/cookie"
require_relative "ebrary-dl/login"
require_relative "ebrary-dl/downloader"
require_relative "ebrary-dl/config/config"
require_relative "ebrary-dl/"

module Ebrary
	module Dl
		GEM_NAME = "ebrary-dl"

		# 20px
		PAGE_POS_OFFSET = 20

		GEM_LIB_DIR = __dir__
		COOKIE_DIR_NAME = "cookies"
		COOKIE_FILE_NAME = "cookies.txt"
		DOCID_DIR_NAME = "cookies"
		DOCID_FILE_NAME = "docid.txt"
		DATA_DIR_NAME = "data"

		BUF_SIZE = 4096

		$page_height = nil
		$view_height = nil
		$view_doc_url = nil
		$cookie_filename = File.join(GEM_LIB_DIR, GEM_NAME, COOKIE_DIR_NAME, COOKIE_FILE_NAME)
		$docid_filename = File.join(GEM_LIB_DIR, GEM_NAME, DOCID_DIR_NAME, DOCID_FILE_NAME)
	end
end
