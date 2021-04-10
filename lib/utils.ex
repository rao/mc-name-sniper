defmodule OgSniper.Utils do

    def username_to_uuid(desired_name) do
        days_ago = :os.system_time(:second) - 3196800

        %HTTPoison.Response{body: body} = HTTPoison.get!("https://api.mojang.com/users/profiles/minecraft/" <> desired_name <> "?at=" <> Integer.to_string(days_ago))

        body
        |> Poison.decode!
        |> Map.get("id")

    end

    def get_change_timestamp(uuid) do
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://api.mojang.com/user/profiles/" <> uuid <> "/names")

        body
        |> Poison.decode!
        |> List.last
        |> Map.get("changedToAt")
        |> Kernel./(1000)
    end

    def add_37_days(changedToAt) do
        time_now = :os.system_time(:second)
        moment_of_change = changedToAt + 3196800

        cond do
            moment_of_change > time_now ->
                {:ok, moment_of_change}
            moment_of_change < time_now ->
                {:error}
        end
    end

    def make_indian_worker_get_captcha_id do
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://2captcha.com/in.php?key=2CAPTCHAKEY&method=userrecaptcha&googlekey=6LfbsiMUAAAAAOu1nGK8InBaFrIk17dcbI0sqvzj&invisible=1&pageurl=https://my.minecraft.net/en-us/login/?return_url=/en-us/redeem/minecraft/")

        body = body
        |> String.replace("OK|", "")
    end

    def attempt_minecraft_auth(minecraft_email, minecraft_password, captchaToken) do
        %HTTPoison.Response{body: body} = HTTPoison.post!("https://authserver.mojang.com/authenticate", Poison.encode!(%{
            "captcha" => captchaToken,
            "captchaSupported" => "InvisibleReCAPTCHA",
            "password" => minecraft_password,
            "username" => minecraft_email,
            "requestUser" => true
            }), [{"Content-Type", "application/json"}])

        body
        |> Poison.decode!
        |> Map.get("accessToken")
    end

    def snipe_process(access_token, desired_name) do
        HTTPoison.put!(
            "https://api.mojang.com/user/profile/agent/minecraft/name/#{desired_name}",
            "",
            [{"Authorization", "Bearer #{access_token}"},
            {"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36"},
            {"Origin", "https://my.minecraft.net"},
            {"Referer", "https://my.minecraft.net/en-us/redeem/minecraft/"},
            {"Accept", "*/*"}]
        )

        HTTPoison.post!("https://api.mojang.com/token/redeem", Poison.encode!(%{
            "code" => "1231231234",
            "languageCode" => "en-us",
            "productType" => "GAME"
            }),
        [{"Authorization", "Bearer #{access_token}"},
        {"Accept", "application/json, text/javascript, */*; q=0.01"},
        {"Content-Type", "application/json"},
        {"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36"}]
        )
    end

end
