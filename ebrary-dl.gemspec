Gem::Specification.new do |s|
	s.name			= "ebrary-dl"
	s.version		= "0.1.1"
	s.date			= "2017-02-14"
	s.summary		= "This is an ebook downloader on ebrary website."
	s.description	= "This is an ebook downloader on ebrary website that downloads pages as image files."
	s.authors		= ["bedew"]
	s.email			= "sunhe1007@126.com"
	# TODO
	s.files			= ["lib/hola.rb"]
	s.homepage		= "https://github.com/bidiu/ebrary-downloader"
	s.license		= "MIT"

	s.add_runtime_dependency "selenium-webdriver", ["= 3.0.5"]
	s.add_runtime_dependency "json", ["= 1.8.3"]
	s.add_runtime_dependency "http", ["= 2.2.1"]
end
