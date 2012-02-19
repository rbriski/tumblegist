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

        gists.each do | gist | 
          if Tumblegist.duplicate?(gist)
            $stderr.puts "#{gist.id} is a duplicate."
          else
            $stderr.puts "Adding #{gist.id}..."
            Tumblegist.publish gist
          end
        end
      end
    end
  end
end