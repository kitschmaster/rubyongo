module TestHelpers
  def tunein
    env 'rack.session', :csrf => 'super-fake-token'
    post "/auth/in", { "guru" => { "username" => app.settings.usr, "password" => app.settings.pas }, :authenticity_token => "super-fake-token"}
  end


  def tuneout
    post "/auth/out"
  end
end