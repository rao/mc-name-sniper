defmodule OgSniper.Ninja do
    defstruct name_to_snipe: nil,
              snipe_at_timestamp: nil,
              mojang_email: nil,
              mojang_password: nil,
              minecraft_email: nil,
              minecraft_password: nil,
              giftcode: nil,
              captcha_token: nil

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

    def handle_info({:start_sniping_process}, state) do  # http requests and all that, collect the cookie too
        # this is where we need to start signing into mojang 
        IO.puts ("It's time to log into Mojang/Minecraft for the account #{state.name_to_snipe}")

        snipe_in = state.snipe_at_timestamp - :os.system_time(:second)
        
        # Process.send(self(), {:set_captcha_token})

        OgSniper.Utils.send_captcha


        Process.send_after(self(), {:snipe1}, round(snipe_in * 1000))

        {:noreply, state}
    end

    # def handle_cast({:set_captcha_token, token}, state) do
    #     Task.start(fn ->
    #         HTTPoison.post!("https://2captcha.com/in.php?key=bbe7d8b5a2b151828c8268ae93334bae&method=userrecaptcha&googlekey=6LfbsiMUAAAAAOu1nGK8InBaFrIk17dcbI0sqvzj&invisible=1&pageurl=https://my.minecraft.net/en-us/redeem/minecraft/#redeem")
    #     end)


    #     {:noreply, %{state | captcha_token: token}}
    # end

    def handle_info({:snipe1}, state) do
        # this is the actual snipe itself
        snipe_in = state.snipe_at_timestamp - :os.system_time(:second)
        IO.puts ("First snipe for #{state.name_to_snipe}")

        {:noreply, state}
    end
end

# def attempt_mojang_auth(email, password, captcha) do
#     HTTPoison.post!("https://authserver.mojang.com/authenticate", Poison.encode!(%{
#     "captcha" => captcha,
#     "captchaSupported" => "InvisibleReCAPTCHA",
#     "password" => password,
#     "username" => email,
#     "requestUser" => true
#      }),[{"Content-Type", "application/json"}])
# end
