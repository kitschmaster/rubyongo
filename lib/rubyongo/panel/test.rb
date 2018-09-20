module Rubyongo
  class Test < Minitest::Test
    include Rack::Test::Methods

    def app
      Rubyongo::Kit
    end
  end

  class Spec <  Minitest::Capybara::Spec
  end
end