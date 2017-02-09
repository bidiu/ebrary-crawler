class MyCookie
	def self.save_cookies(cookie_enumerator)
		f = File.new($cookie_filename, "w")
		cookie_enumerator.each do |cookie|
			f.puts cookie.to_json
		end
		f.close
	end

	# if there's no cookie file, return nil
	def self.load_cookies
		return nil unless File.file?($cookie_filename)

		cookies = []
		f = File.new($cookie_filename, "r")
		f.each_line do |line|
			cookies << JSON.parse(line, symbolize_names: true)
		end
		f.close
		cookies
	end

	def self.save_docid(docid)
		f = File.new($docid_filename, "w")
		f.puts docid
		f.close
	end

	# if there's no docid file, return nil
	def self.load_docid
		return nil unless File.file?($docid_filename)
		File.read $docid_filename
	end

	# clear all local saved cookies and docid
	def self.clear
		File.delete $cookie_filename if File.file? $cookie_filename
		File.delete $docid_filename if File.file? $docid_filename
	end
end
