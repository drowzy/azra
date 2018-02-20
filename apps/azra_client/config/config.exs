# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :azra_client, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:azra_client, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
config :azra_client,
  rancher: %{
    project: {:system, "AZRA_RANCHER_PROJECT", ""},
    url: {:system, "AZRA_RANCHER_URL", ""},
    access_key: {:system, "AZRA_RANCHER_ACCESS_KEY", ""},
    selector_key: {:system, "AZRA_RANCHER_SELECTOR", "image"},
    secret: {:system, "AZRA_RANCHER_SECRET", ""},
    mode: {:system, "AZRA_CLIENT_MODE", "mixed"}
  }

config :azra_client,
  server: %{
    url: {:system, "AZRA_SERVER", "localhost:50051"},
    provider: {:system, "AZRA_PROVIDER", "azure"}
  }

config :azra_client,
  client: %{
    receiver_port: {:system, "AZRA_RECEIVER_PORT", 4000}
  }
