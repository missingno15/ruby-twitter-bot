# Uncomment the following if you are running Windows. Noob.(jkjk)
# ENV['SSL_CERT_FILE'] = File.expand_path("cacert.pem")

require 'yaml'
require 'twitter'

class TwitterBot
  puts "Loading Twitter API keys...."
  TWITTER = YAML.load_file('config.yaml')

  puts "Loading your Twitter messages to be tweeted...."
  MESSAGES = File.readlines('messages.txt')
 
  CLIENT = Twitter::REST::Client.new do |config|
    config.consumer_key = TWITTER['CONSUMER_KEY']
    config.consumer_secret = TWITTER['CONSUMER_SECRET']
    config.access_token = TWITTER['ACCESS_TOKEN']
    config.access_token_secret = TWITTER['ACCESS_TOKEN_SECRET']
  end
  

  @reminder_counter = 0

  def self.loop_tweets
    puts "Twitter Bot initialized."

    at_these_intervals = set_time 
    puts "Tweets will be sent out every #{@hours} hour(s) and #{@minutes} minute(s)"
    
    MESSAGES.shuffle!

    loop do
      MESSAGES.each do |message|
        CLIENT.update(message)
        puts "Twitter Bot has tweeted the following message:"
        puts "\n#{message}\n"
    
        update_counter
        show_reminder

        MESSAGES.shuffle! if MESSAGES[-1] == message
        sleep at_these_intervals
      end

    end
  end
  
  private 
  class << self
    def update_counter
      @reminder_counter += 1
    end

    def show_reminder
      if @reminder_counter == 3
        puts "Remember, to shut off the application, do Ctrl+C or simply exit out of Terminal/Command Prompt."
        @reminder_counter = 0
      end
    end

    def set_time
      puts "Set time interval between tweets. Enter it in this format: hh:mm | e.g. '01:48' is 1hr 48minutes"
      print "> "
      interval_input = gets.chomp.strip

      tweet_interval = convert_interval_to_seconds(interval_input)
       
      tweet_interval
    end

    def convert_interval_to_seconds(interval)
      @hours, @minutes = interval.split(":")[0].to_i, interval.split(":")[1].to_i

      hours_in_seconds = @hours * 3600
      minutes_in_seconds = @minutes * 60
      total_time_in_seconds = hours_in_seconds + minutes_in_seconds

      total_time_in_seconds
    end

  end
end


TwitterBot.loop_tweets
