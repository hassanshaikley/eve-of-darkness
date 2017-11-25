use Mix.Config

# Speed Up Tests When Hashing Passwords
config :pbkdf2_elixir, :rounds, 1

config :eve_of_darkness, EOD.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("EOD_DATABASE_NAME") || "eod_test",
  username: System.get_env("EOD_DATABASE_USERNAME") || "postgres",
  password: System.get_env("EOD_DATABASE_PASSWORD") || "postgres",
  hostname: System.get_env("EOD_DATABASE_HOSTNAME") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
