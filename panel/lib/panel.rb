# Write your Panel backend code here.

# Example authenticated test view:
get '/test' do
  auth! # this will ask for the configured password, see panel.yml
  erb :test
end

