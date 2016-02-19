require "jumpstart_auth"
require "bitly"
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end #initialize

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "You're tweet is #{message.length - 140} characters too long. Shorten it up and try again!"
    end
  end #tweet

  def dm(target, message)
    puts "Trying to send #{target} the following direct message:"
    puts message
    message = "d @#{target} #{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      tweet(message)
    else
      puts "Sorry, you can only direct message people who already follow you."
    end
  end

  def spam_my_followers(message)
    list = followers_list
    list.each do |follower|
      dm(follower, message)
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    return screen_names
  end

  def everyones_last_tweet
    friends = @client.friends.collect {|friend| @client.user(friend)}
    friends.sort_by! do |friend|
      friend.screen_name.downcase
    end
    friends.each do |friend|
      timestamp = friend.status.created_at
      puts "#{friend.screen_name}'s | #{timestamp.strftime("%A, %b %d - %H:%M")}"
      puts friend.status.text
      puts
    end
  end

  def tweet_url(parts)
    tweet("#{parts[1..-2].join(" ")} #{short_link(parts[-1])}")
  end

  def short_link(url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(url).short_url
  end

  def run
    puts "Welcome to your new Twitter client"
    command = ""
    while command != "q"
      print "Enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when "q" then puts "Goodbye!"
        when "t" then tweet(parts[1..-1].join(" "))
        when "dm" then dm(parts[1], parts [2..-1].join(" "))
        when "s" then short_link(parts[1..-1])
        when "turl" then tweet_url(parts)
        when "spam" then spam_my_followers(parts[1..-1].join(" "))
        when "last" then everyones_last_tweet
        else puts "Sorry, I don't know how to #{command}"
      end
    end
  end #run

end #MicroBlogger

blogger = MicroBlogger.new
blogger.run
