module Tumblegist
  module Jobs
    module PullGists
      extend self

      def perform
        gists = Tumblegist::Gist.public
        new_gists = gists.reject { | gist | Tumblegist.duplicate?(gist) }

        new_gists.each do | gist | 
          $stderr.puts "Adding #{gist.id}..."
          Tumblegist.publish gist
        end
      end
    end
  end
end