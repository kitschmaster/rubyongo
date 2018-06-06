module Rubyongo
  class Kit < Sinatra::Base
    # Write your Panel backend code here.

    # Example microservice:
    #
    get '/microservice' do
      json Guru.test
    end

  end
end