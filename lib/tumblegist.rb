require 'bundler/setup'
require 'configliere'
require 'httparty'
require 'active_support/core_ext'
require 'hashie'
require 'redis'
require 'pubnub'

Settings.use :define, :config_file
Settings({
  :dedup_expiration => 6.hours.to_i,
  :pubnub => {
    :channel => 'gists'
  }
})

Settings.read(File.expand_path("../../config/settings.yml",  __FILE__))
Settings.resolve!

module Tumblegist
  extend self

  def redis
    @redis ||= Redis.connect :url => Settings[:redis][:url]
  end

  def pubnub
    @pubnub ||= Pubnub.new(Settings[:pubnub][:pub_key], Settings[:pubnub][:sub_key], '', false)
  end

  # This makes a huge difference in the amount of memory used by
  # redis.  Storing integers in a set (or list, etc) allows redis
  # to encode the members in an efficient way
  # http://redis.io/topics/memory-optimization
  def duplicate? gist
    current_set = "gists_#{DateTime.now.strftime("%Y%m%d%H")}"
    redis.sadd "gist_sets", current_set
    key = gist.id.to_i

    redis.smembers("gist_sets").each do | gist_set |

      # If it's expired, remove it from the master set
      unless redis.exists(gist_set)
        redis.srem "gists_sets", gist_set
        next
      end

      return true if redis.sismember gist_set, key
    end

    redis.sadd current_set, key
    redis.expire current_set, Settings[:dedup_expiration]

    return false
  end

  def publish gist
    response = pubnub.publish({
      'channel' => Settings[:pubnub][:channel],
      'message' => gist.mash.to_hash
    })

    $stderr.puts response.inspect
  end
    
end


require 'tumblegist/gist'
require 'tumblegist/jobs'