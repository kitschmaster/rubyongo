module Rubyongo
  class Test < Minitest::Test
    include Rack::Test::Methods

    def app
      Rubyongo::Kit
    end
  end

  class Spec < Minitest::Test
    include Capybara::DSL
    def setup
      Capybara.app = Rubyongo::Kit.new
    end
  end
end