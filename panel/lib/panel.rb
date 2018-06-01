module Rubyongo
  class Kit < Sinatra::Base
    # Write your Panel backend code here.

    # Example test view:
    get '/test' do
      erb :test
    end
  end
end