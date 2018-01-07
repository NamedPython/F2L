# frozen_string_literal: true

require 'bundler/setup'
require 'twitter'
require 'dotenv'

# load each env-var
def init
  Dotenv.load

  Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['CONSUMER_KEY']
    config.consumer_secret = ENV['CONSUMER_SECRET']
    config.access_token = ENV['ACCESS_TOKEN']
    config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
  end
end

def load_filters(filename)
  filters = []
  print 'loading filters...'
  unless File.exist?(filename)
    puts 'file not found, create a filter file and run again.'
    File.new(filename, 'w')
    exit(-1)
  end
  File.open(filename, 'r') do |f|
    f.each do |filter|
      puts filter
      filters << filter.to_s.chomp!
    end
  end
  puts 'done'
  filters
end

def following(client)
  users = {}
  cursor = -1
  while cursor != 0
    begin
      puts 'getting friends...'
      attrs = client.friends(cursor: cursor, count: 200).attrs
      attrs[:users].each do |user|
        users.store(user[:id], "#{user[:description]} #{user[:entities]}")
        puts "stored: #{user[:id]} -> #{user[:description]} #{user[:entities]}"
      end
      cursor = attrs[:next_cursor]
    rescue Twitter::Error::TooManyRequests => error
      puts 'failed, retry after rate limit reset.'
      sleep error.rate_limit.reset_in + 1
      puts 'gonna retry'
      retry
    end
    puts 'done'
  end
  users
end

def extract(filters, users)
  result = []
  users.each do |id, desc|
    puts "**********  #{id}  **********"
    filters.each do |filter|
      puts "check match with #{filter}..."
      if desc.match?(/#{filter}/i)
        result << id
        puts "#{$&} -> matched! #{id} will be moved!"
        break
      else puts 'unmatched'
      end
    end
  end
  puts 'complete extract'
  result
end

def unfollow_all(client, users)
  users.each do |user|
    begin
      client.unfollow(user)
      print "unfollowing #{user} ..."
    rescue Twitter::Error::TooManyRequests => error
      puts 'failed, retry after rate limit reset.'
      sleep error.rate_limit.reset_in + 1
      puts 'gonna retry'
      retry
    end
    puts 'ok'
  end
  puts 'complete unfollow process'
end

def move_to_list(client, users)
  sliced = users.each_slice(100).to_a
  begin
    list_id = client.list('f2l').id
  rescue Twitter::Error::NotFound => error
    list_id = client.create_list('f2l')
  end
  sliced.each do |l|
    begin
      print 'moving next people to the list...'
      client.add_list_members(list_id, l)
    rescue Twitter::Error::TooManyRequests => error
      puts 'failed, retry after rate limit reset.'
      sleep error.rate_limit.reset_in + 1
      puts 'gonna retry'
      retry
    end
    puts 'done'
  end
end

client = init

filters = load_filters('filter_include.txt')

following_users = following(client)

extracted = extract(filters, following_users)

unfollow_all(client, extracted)

move_to_list(client, extracted)
