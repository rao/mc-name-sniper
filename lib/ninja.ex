defmodule OgSniper.Ninja do
    defstruct desired_name: nil,
              access_token: nil,
              snipe_at_timestamp: nil,
              minecraft_email: nil,
              minecraft_password: nil,
              captcha_token: nil,
              captcha_id: nil

    use GenServer

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: :"#{state.desired_name}")
    end

    def init(state) do
        snipe_in = state.snipe_at_timestamp - :os.system_time(:second)
        IO.puts state.snipe_at_timestamp
        # Sends a message to start sniping 2 minutes before the name drops
        IO.puts round(snipe_in * 1000)
        Process.send_after(self(), {:start_sniping_process}, round((snipe_in - 60) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in - 1) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.75) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.5) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.25) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in + 0.25) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in + 0.5) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in + 0.75) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in + 1) * 1000))
        {:ok, struct(__MODULE__, state)}
    end

    def handle_info({:start_sniping_process}, state) do  # http requests and all that, collect the cookie too
        # this is where we need to start signing into mojang 
        IO.puts ("It's time to log into Minecraft for the account #{state.desired_name}")

        captcha_id = OgSniper.Utils.make_indian_worker_get_captcha_id

        Process.send_after(self(), {:get_captcha_token}, 20000)

        {:noreply, %{state | captcha_id: captcha_id}}
    end

    def handle_info({:get_captcha_token}, state) do
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://2captcha.com/res.php?key=bbe7d8b5a2b151828c8268ae93334bae&action=get&id=#{state.captcha_id}")

        captcha_token = body |> String.replace("OK|", "")

        Process.send_after(self(), {:minecraft_auth}, 2000)

        {:noreply, %{state | captcha_token: captcha_token}}
    end

    def handle_info({:minecraft_auth}, state) do

        access_token = OgSniper.Utils.attempt_minecraft_auth(state.minecraft_email, state.minecraft_password, state.captcha_token)

        IO.puts(access_token)

        {:noreply, %{state | access_token: access_token}}
    end

    def handle_info({:snipe1}, state) do
        # this is the actual snipe itself
        IO.puts ("Snipe going through for #{state.desired_name}, let's cook boys")

        OgSniper.Utils.snipe_process(state.access_token, state.desired_name)

        {:noreply, state}
    end
end
