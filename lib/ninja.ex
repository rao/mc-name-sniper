defmodule OgSniper.Ninja do
    defstruct name_to_snipe: nil,
              snipe_at_timestamp: nil,
              mojang_email: nil,
              mojang_password: nil,
              minecraft_email: nil,
              minecraft_password: nil,
              giftcode: nil

    use GenServer

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: :test)
    end

    def init(state) do
        snipe_in = state.snipe_at_timestamp - :os.system_time(:second) - 180
        IO.puts state.snipe_at_timestamp
        # Sends a message to start sniping 3 minutes before the name drops
        IO.puts round(snipe_in * 1000)
        Process.send_after(self(), {:start_sniping_process}, round(snipe_in * 1000))
        {:ok, struct(__MODULE__, state)}
    end

    def handle_info({:start_sniping_process}, state) do
        # this is where we need to start signing into mojang 
        snipe_in = state.snipe_at_timestamp - :os.system_time(:second)
        IO.puts ("It's time to log into Mojang/Minecraft for the account #{state.name_to_snipe}")

        # http requests and all that, collect the cookie too

        %HTTPoison.Response{body: cookie} = HTTPoison.get("https://my.minecraft.net/en-us/login/?return_url=/en-us/redeem/minecraft/")

        cookie
        |> Poison.decode!

        Process.send_after(self(), {:snipe1}, round(snipe_in * 1000))

        {:noreply, state}
    end

    def handle_info({:snipe1}, state) do
        # this is the actual snipe itself
        snipe_in = state.snipe_at_timestamp - :os.system_time(:second)
        IO.puts ("First snipe for #{state.name_to_snipe}")

        {:noreply, state}
    end
end
