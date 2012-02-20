module Tumblegist
  module Jobs
    module PullGists
      extend self
      extend HerokuResqueAutoScale

      def queue
        :tumblegist
      end

      def perform
        gists = Tumblegist::Gist.public

        already_sent = Tumblegist::Store.ids
        new_gists = gists.reject { | gist | already_sent.include?(gist.id.to_i) }

        new_gists.each do | gist | 
          begin
            $stderr.puts "Adding #{gist.id}..."
            Tumblegist.publish gist
            Tumblegist::Store.add gist.id
          rescue OpenURI::HTTPError => e
            $stderr.puts "Can't add #{gist.id}..."
            $stderr.puts gist.mash.inspect
          end
        end
      end
    end
  end
end