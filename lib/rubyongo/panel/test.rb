module Rubyongo
  class Test < Minitest::Test
    include ::Rack::Test::Methods

    def app
      Rubyongo::Kit
    end
  end

  if defined?(Minitest::Capybara::Spec)
    class Spec <  Minitest::Capybara::Spec
    end
  end
end