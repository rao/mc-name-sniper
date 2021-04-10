use Mix.Config

config :og_sniper,
    desired_name: "desired_name",
    minecraft_email: "minecraft@email.com",
    minecraft_password: "minecraft_password"

import_config "#{Mix.env()}.exs}"