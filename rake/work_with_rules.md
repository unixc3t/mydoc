#### Understanding the duplication of the file tasks

> 前面章节，我们编写了blog生成器， 让我们修正一下我们前面写的代码

	require_relative 'blog_generator'
	articles = Rake::FileList.new('**/*.md','**/*.markdown') do |files|
		           files.exclude('~*')
				   files.exclude(/^temp.+\//)
				   files.exclude do |file|
	                  File.zero?(file)
				  end
	end

	*task :default => 'blog.html'
	articles.ext.each do |article|
		file "#{article}.html" => "#{article}.md" do
			sh "pandoc -s #{article}.md -o #{article}.html"
		end
	file "#{article}.html" => "#{article}.markdown" do
		sh "pandoc -s #{article}.markdown -o #{article}.html"
		end
	end
	*
	FileUtils.rm('blog.html', force: true)
	file 'blog.html' => articles.ext('.html') do |t|
		BlogGenerator.new(t).perform
	end
