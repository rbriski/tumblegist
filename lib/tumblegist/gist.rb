module Tumblegist
  class Gist
    include HTTParty
    base_uri 'https://api.github.com'
    attr_reader :mash

    class << self
      def auth
        {:username => Settings[:git][:username], :password => Settings[:git][:password]}
      end

      def public *args
        options = args.extract_options!

        options.merge!({:basic_auth => auth})
        gists = self.get('/gists/public', options)

        gists.map { | g | self.new(g) }
      end
    end

    def initialize result_hash
      @mash = Hashie::Mash.new(result_hash)
    end

    def method_missing meth, *args, &block
      if @mash.respond_to?(meth)
        @mash.send(meth, *args)
      else
        super
      end
    end
  end
end

