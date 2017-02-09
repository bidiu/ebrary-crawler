require "http"
require "uri"
require "cgi"
require "singleton"
require "./global.rb"

class Downloader
	include Singleton

	attr_reader :book_title, :dir, :header_cookie

	def initialize
		@book_title = $book_title
		@dir = File.join CUR_DIR, "..", DATA_DIR_NAME, @book_title
		Dir.mkdir(@dir) unless File.directory?(@dir)

		HTTP.timeout(:global, connect: $request_timeout, read: $request_timeout)
		# prepare cookie header
		@header_cookie = ""
		MyCookie.load_cookies.each do |cookie|
			@header_cookie << "#{cookie[:name]}=#{cookie[:value]}; "
		end
		@header_cookie.chomp("; ")
	end

	# TODO retry logic
	def download(url, page_no)
		parameters = {}
		CGI::parse(URI(url).query).each do |name, values|
			parameters[name] = values[0]
		end
		response = HTTP.headers(
					accept: "image/webp,image/*,*/*;q=0.8",
					accept_encoding: "gzip, deflate, sdch",
					accept_language: "en,zh-CN;q=0.8,zh;q=0.6",
					cookie: @header_cookie,
					host: $download_host,
					referer: $view_doc_url,
					user_agent: $user_agent)
					.get(url, params: parameters)
		if response.code == 200
			f = File.new(File.join(@dir, "#{page_no}.png"), "w")
			begin
				while bytes = response.body.readpartial(BUF_SIZE)
					write_file(bytes, f)
				end
			ensure
				f.close
			end
		else
			# TODO
		end
	end

	def last_downloaded_page_no
		docs = Dir.entries("#{@dir}").reject! { |filename| not filename.end_with? ".png" }
		docs.sort! do |v1, v2|
			v1.chomp(".png").to_i <=> v2.chomp(".png").to_i
		end
		return docs.empty? ? 1 : /^\d+/.match(docs.last).to_s.to_i
	end

	def detect_view_page_height(driver)
		async_element(:css, "#mainViewerImgCloakWrapper_1 img", driver,
							times: $max_try, timeout: $request_timeout)
		if not $page_height
			$page_height = driver.execute_script(
							"return document.getElementById(\"mainViewerImgCloakWrapper_1\").style.height").to_i
			$view_height = driver.execute_script(
							"return document.getElementById(\"mainViewerPagesContainerWrapper\").style.height").to_i
		end
	end

private
	def write_file(bytes, f)
		f.write(bytes)
	end
end
