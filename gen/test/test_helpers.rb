module TestHelpers
  def tunein
    post "/auth/in", { "guru" => { "username" => app.settings.usr, "password" => app.settings.pas } }
  end

  def tuneout
    post "/auth/out"
  end
end