
#### The need for tests

> rake任务通常不作为应用程序的常规代码运行，考虑这种情况，你有一个web程序使用了rake task,但是没有被测试，在部署代码到服务器之后，手动测试web程序
> 通过web接口， 你很有信心这个web程序工作正常。然而,因为这些rake takes按周期运行，或许有一次失败了， 当某次rake take执行， 这个rake task没有工作，
> 因为它没有被测试，

> 例如，每个rails程序有一个db:seed task,这个rake经常被用来初始化程序，使用一些基本数据，例如包含创建超级管理代码， 代码在db/seeds.rb目录下定义
> 目录在rails程序的根目录下 例如下面代码
	
	User.create!({
		:admin => 'example@email.com',
		:password => 'password'
	})

> 假设我们有一天使用这个代码，手动执行了这个rake db:seed从命令行，几天后，我们决定加入name验证， 上面代码不能工作了。但是我们没有测试这个db:seed task
> 所有其他测试都通过了，我们准备部署这个程序，因为所有人都忘记这个代码，没人知道他根本不会工作， 当程序部署到服务器时才会被发现，这时，我们或许有很多过时的任务，
> 这些问题总是不断出现，直到我们打算编写测试


#### Writing tests for rake tasks

> 现在，当你准备编写测试时，想知道怎么做，为了说明这个，假设我们有一个rake 任务，叫做send_mail,有两个可选的参数，subject和body,
> 这个任务将给定的字符串写成一个sent_email.txt文件

> 下面是一个基本的mailer程序在rake task中使用
	
	class Mailer
		DESTINATION = 'sent_email.txt'.freeze
		DEFAULT_SUBJECT = 'Greeting!'
		DEFAULT_BODY = 'Hello!'

		def initialize(options = {})
			@subject = options[:subject] || DEFAULT_SUBJECT
			@body = options[:body] || DEFAULT_BODY
		end
		
		def send
			puts 'Sending email...'
			File.open(DESTINATION, 'w') do |f|
				f << "Subject: #{@subject}\n"
				f << @body
			end

	        puts 'Done!'
		end
	end

> 这个类的接口很简单，初始化方法接收subject和body作为hash的参数， 然后我们使用send方法在类对象上，创建sent_email.txt
> 下面是Rakefile文件

	require 'rake/clean'
	require_relative './mailer'
	CLOBBER.include(Mailer::DESTINATION)
	desc "Sending email. The email is saved to the file   #{Mailer::DESTINATION}"
	task :send_email, :subject, :body do |t, args|
		Mailer.new({
			:subject => args.subject,
			:body => args.body
		}).send
	end
	

> 如你所见，这不复杂，紧挨着你定义的send_email任务旁边有一个clobber任务，用来移除生成的sent_email.txt
> 这个send_email任务的参数通过命令行传递， 我们可以使用下面方式检查
	

	$ rake send_email
	Sending email...
	Done!
	$ cat sent_email.txt
	Subject: Greeting!
	Hello!
	$ rake "send_email[Test, Hi]"
	Sending email...
	Done!
	$ cat sent_email.txt
	Subject: Test
	Hi
	$ rake clobber

> 现在我们讨论这个最终文件，这有许多测试框架，我们仅仅需要使用内置的MiniTest 

> 现在尝试测试这个任务， 这些测试包括send_email和clobber任务，测试文件在test目录里，test目录在send_email类文件所在目录里，


	require 'minitest/autorun'
	require 'rake'

	class TestSendEmail < MiniTest::Unit::TestCase
		def setup
			Rake.application.init
			Rake.application.load_rakefile
			@task = Rake::Task[:send_email]
			@task.reenable
		end

		def teardown
			if File.exists?(Mailer::DESTINATION)
				File.delete(Mailer::DESTINATION)
			end
		end

		def test_sending_email_with_default_params
			@task.invoke
			assert_equal email, "Subject: Greeting!\nHello!"

	     end

		 def test_sending_email_with_custom_subject_and_body
			 @task.invoke('Test', 'Hi!')
			 assert_equal email, "Subject: Test\nHi!"
		 end
	   	 def test_clobber_task_deletes_email
			 @task.invoke
			 Rake::Task[:clobber].invoke
			 refute File.exists?(Mailer::DESTINATION)
		 end

		 private
		 def email
			 File.readlines(Mailer::DESTINATION).join
		 end
	 end

> 让我们弄清楚上面代码做了什么，开始。我们查看setup方法，这个方法是测试rake task的基石， 想要测试一个task,我们首先要初始化这个Rake程序
> 请注意，我们没有使用rake工具，在这些tasks里。通过命令行调用这些代码会使得测试变得低效率， 例如，在这个例子里，我们没有访问这个rake 任务的
> 内部，所有我们不能使用Stubs,但是有时，使用假类替换真类是合理的

> 在初始化Rake程序后，我们得到了rake 任务，并保存到@task变量里， 这个变量可以被每个test所访问， setup方法最后一行允许我们运行这个rake任务
> 若干次,默认情况，rake统计task的运行次数。不允许我们重复调用raker任务， 这行代码重置了计数器，提供我们多次运行任务的机会,

> teardown方法后面就是测试本身。两个测试send_email的方法和一个测试clobber的方法

> 第一个测试是执行rake没使用参数
> 第二个测试接收命令行参数 subject和body
> 第三个测试用来测试clobber任务应该删除生成的文件

> 注意测试文件被放在制定的子目录，test里，

	$ ruby test/send_mail_test.rb
	
>输出结果如下
	
	MiniTest::Unit::TestCase is now Minitest::Test. From test/send_email_
	test.rb:4:in `<main>'
	Run options: --seed 19500

    # Running:

	Sending email...
	Done!
	.Sending email...
	Done!
	Sending email...
	Done!
	.Sending email...
	Done!
	Sending email...
	Done!

	Sending email...
	Done!
	.
	Finished in 0.013278s, 225.9376 runs/s, 225.9376 assertions/s.
	3 runs, 3 assertions, 0 failures, 0 errors, 0 skips
