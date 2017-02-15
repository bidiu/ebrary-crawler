Gem::Specification.new do |spec|
	spec.name			= "ebrary-dl"
	spec.version		= "0.1.1"
	spec.date			= "2017-02-14"
	spec.summary		= "This is an ebook downloader on ebrary website."
	spec.description	= "This is an ebook downloader on ebrary website that downloads pages as image files."
	spec.authors		= ["bedew"]
	spec.email			= "sunhe1007@126.com"
	# TODO
	spec.files			= Dir["lib/**/*.rb"] + Dir["bin/*"]
	spec.files.reject! do |filename|
		filename.include? "config.rb"
	end
	spec.homepage		= "https://github.com/bidiu/ebrary-downloader"
	spec.license		= "MIT"

	spec.add_runtime_dependency "selenium-webdriver", ["= 3.0.5"]
	spec.add_runtime_dependency "json", ["= 1.8.3"]
	spec.add_runtime_dependency "http", ["= 2.2.1"]

	spec.executables << "ebrary-dl" << "ebrary-cl"
end
