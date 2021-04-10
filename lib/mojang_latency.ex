defmodule OgSniper.MojangLatency do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, [], name: :mojang_latency)
    end

    def init(state) do
        Process.send(self(), :fetch, [])
        {:ok, state}
    end

    def handle_call(:latency, _from, state) do
        total = Enum.reduce(state, fn x,y -> x + y end)
        avg = total / length(state)
        {:reply, avg, state}
    end

    def handle_info(:fetch, state) do
        {microseconds, result} = :timer.tc(fn -> HTTPoison.get!("https://api.mojang.com/user/profiles/2d7ee112676946cb99793022ea7326f9/names") end) # https://api.mojang.com/user/profiles/c8a57bd5d5f44e8fbd1ed1760feff0cd/names
        milliseconds = System.convert_time_unit(microseconds, :microsecond, :millisecond)
        IO.puts milliseconds

        Process.send_after(self(), :fetch, 5000)
        {:noreply, Enum.slice([milliseconds | state], 0..49)}

    end
end
