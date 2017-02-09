require "http"
require "singleton"
require "./global.rb"

class Downloader
	include Singleton

	attr_reader :book_title, :dir

	def initialize
		@book_title = $book_title
		@dir = File.join CUR_DIR, "..", DATA_DIR_NAME, @book_title
		Dir.mkdir(@dir) unless File.directory?(@dir)
	end

	def download(url, page_no)
		# TODO
		puts "[#{page_no}]: #{url}"
	end

	def last_downloaded_page_no
		# TODO
	end
end
