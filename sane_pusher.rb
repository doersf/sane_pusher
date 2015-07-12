require 'oj'
require 'oj_mimic_json'
require 'figaro'
require 'redis'
require 'hiredis'
require 'pusher'
require 'securerandom'

Figaro.application.path = ENV["FIGARO_CONFIG"]
Figaro.load

$stdout.sync = true

Pusher.app_id = ENV['PUSHER_APPID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']
Pusher.host = ENV['PUSHER_HOST']
Pusher.port = ENV['PUSHER_PORT'].to_i

$redis = Redis.new(:driver => :hiredis) # use localhost's redis-server

rand_id = SecureRandom.hex(4)

while (true) do

  msg = Oj.load($redis.brpop('pusher_queue').last)

  Pusher.trigger(msg['channel'], msg['event'], msg['data'])

  puts "#{Time.now.to_s} #{rand_id} Queue Size: #{$redis.llen('pusher_queue')}"

end
