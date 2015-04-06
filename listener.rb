#!/usr/bin/env ruby

#
# The MIT License (MIT)
#
# Copyright (c) 2015 usandfriends
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

require 'open-uri'
require 'nokogiri'
require 'cinch'

def setInterval(delay)
	Thread.new do
		loop do
			yield
			sleep delay
		end
	end
end

load 'config.rb'

Format = Cinch::Formatting.method('format')

$ids = Marshal.load(File.exists?('ids.bin') ? open('ids.bin').read : "\x04\b[\x00")

$bot = Cinch::Bot.new do
	configure do |c|
		c.server = $config[:server]
		c.nick = $config[:nick]
		c.realname = $config[:realname]
		c.sasl.username = $config[:user]
		c.sasl.password = $config[:password]
		c.channels = $config[:channels]
	end

	on :message, Regexp.new('^' + $config[:nick] + '\\: (.*)?') do |m|
		command = m.message.split(' ')[1..-1].join(' ')
		if m.user.host == $config[:admin] then
			case command
			when 'quit', 'exit', 'die'
				$bot.quit
			when 'start'
				$timer = setInterval(15) {
					$config[:forums].each { |forum|
						Thread.new do
							Nokogiri::HTML(open("http://www.cplusplus.com/forum/#{forum}/")).document.css('.C_forThread table').each { |elem|
								post_id = elem.attr('id')[9..-1]
								post_title = elem.css('tr:nth-child(1) td a b').text.strip

								main_data_elem = elem.css('tr:nth-child(3) td')
								# date_info_elem = main_data_elem.css('div span')

								# date = Date.parse(date_info_elem.attr('title')).strftime('%s').to_i
								replies = main_data_elem.children[2].text.strip().split(' ')[0][1..-1]

								if replies == 'no' && !$ids.include?(post_id) then
									$ids.push(post_id)
									m.channel.send("#{Format(:bold, "New post:")} http://www.cplusplus.com/forum/#{forum}/#{post_id}/ [ #{post_title} ]", true)
								end
							}
						end
					}
				}
			when 'stop', 'shutup'
				$timer.kill
			when 'save', 'backup'
				File.open('ids.bin', 'w') { |f| f.write(Marshal.dump($ids)) }
			end
		else
			m.reply('Denied.')
		end
	end
end

def bot_quit
	puts 'Saving...'
	File.open('ids.bin', 'w') { |f| f.write(Marshal.dump($ids)) }
	puts 'Shutting down...'
	$bot.quit
end

Signal.trap('HUP') { bot_quit; exit }
Signal.trap('TERM') { bot_quit; exit }

begin
	$bot.start
rescue Interrupt
rescue Exception => e
	puts "Caught exception: #{e.message()}"
	puts e.backtrace.join("\n\t")
end

bot_quit
