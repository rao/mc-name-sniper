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
        IO.puts "EPOCH timestamp for #{state.desired_name} is #{state.snipe_at_timestamp}"
        IO.puts "Sniping '#{state.desired_name}' in #{round(snipe_in)} seconds"

        Process.send_after(self(), {:start_sniping_process}, round((snipe_in - 75) * 1000))
        Process.send_after(self(), {:ninja}, round((snipe_in - 15) * 1000))

        {:ok, struct(__MODULE__, state)}
    end

    def handle_info({:ninja}, state) do
        snipe_in = state.snipe_at_timestamp - :os.system_time(:second)
        latency = GenServer.call(:mojang_latency, :latency)
        |> round
        |> IO.inspect
        IO.puts "Grabbed the average latency to mojang.com. Get ready."

        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.6) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.5) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.4) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.19) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.15) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.1) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.01) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.001) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.0001) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.00001) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.000001) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.0000001) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.00000001) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.000000001) * 1000) - latency)
        Process.send_after(self(), {:snipe1}, round((snipe_in - 0.001) * 1000))
        Process.send_after(self(), {:snipe1}, round((snipe_in) * 1000) - latency)
        {:noreply, state}
    end

    def handle_info({:start_sniping_process}, state) do
        captcha_id = OgSniper.Utils.make_indian_worker_get_captcha_id
        IO.puts ("It's time to log into Minecraft for the account #{state.desired_name}")

        Process.send_after(self(), {:get_captcha_token}, 40000)

        {:noreply, %{state | captcha_id: captcha_id}}
    end

    def handle_info({:get_captcha_token}, state) do
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://2captcha.com/res.php?key=2CAPTCHAKEY&action=get&id=#{state.captcha_id}")
        captcha_token = body |> String.replace("OK|", "")
        IO.puts captcha_token

        Process.send_after(self(), {:minecraft_auth}, 2000)

        {:noreply, %{state | captcha_token: captcha_token}}
    end

    def handle_info({:minecraft_auth}, state) do
        access_token = OgSniper.Utils.attempt_minecraft_auth(state.minecraft_email, state.minecraft_password, state.captcha_token)
        IO.puts access_token

        {:noreply, %{state | access_token: access_token}}
    end

    def handle_info({:snipe1}, state) do
        IO.puts ("Snipe going through for #{state.desired_name}.")
        Task.start(fn ->
            OgSniper.Utils.snipe_process(state.access_token, state.desired_name)
        end)

        {:noreply, state}
    end
end
