$: << File.expand_path("lib", File.dirname(__FILE__))
require 'tumblegist'

Dir[Tumblegist.root.join('lib/tasks/*.rake')].each do | taskfile |
  load taskfile
end

