module Rubyongo
  class Test < Minitest::Test
    include Rack::Test::Methods

    def app
      Rubyongo::Kit
    end
  end
end