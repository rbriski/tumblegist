require 'bundler/setup'
require 'configliere'
require 'httparty'
require 'active_support/core_ext'
require 'hashie'
require 'redis'
require 'pubnub'
require 'pg'

Settings.use :define, :config_file
Settings({
  :dedup_expiration => 6.hours.to_i,
  :pubnub => {
    :channel => 'gists'
  },
  :database => {
    :host => 'localhost',
    :port => 5432,
    :dbname => 'tumblegist',
    :user => '',
    :password => ''
  }
})

Settings.read(File.expand_path("../../config/settings.yml",  __FILE__))
Settings.resolve!

module Tumblegist
  extend self

  def root
    @root ||= Pathname.new(File.expand_path("..",  File.dirname(__FILE__)))
  end

  def pubnub
    @pubnub ||= Pubnub.new(Settings[:pubnub][:pub_key], Settings[:pubnub][:sub_key], '', false)
  end

  def publish gist
    response = pubnub.publish({
      'channel' => Settings[:pubnub][:channel],
      'message' => gist.mash.to_hash
    })

    $stderr.puts response.inspect
  end
    
end


require 'tumblegist/store'
require 'tumblegist/gist'
require 'tumblegist/jobs'