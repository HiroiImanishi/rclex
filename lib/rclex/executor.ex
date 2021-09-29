defmodule Rclex.Executor do
    require Rclex.Macros
    require Logger
    use GenServer, restart: :transient

    def start_link(_) do
        GenServer.start_link(__MODULE__, {}, name: Executor)
    end

    def init(_) do
        {:ok, {}} 
    end

    @doc """
        購読開始の準備
        監視されるタスクを生成し，購読ループ処理を実行させる
    """
    def subscribe_start(sub_list, context, call_back) do
        Logger.debug("subscribe start")
        id_list = sub_list
                |> Enum.map(fn sub -> GenServer.call(Executor, {:sub_start_link, sub, context, call_back}) end )
        Logger.debug("subscribe start 2")
        {:ok, id_list}
    end

    @doc """
        プロセスを終了する
    """
    def stop_process(id_list) do
        Logger.debug("start stop process")
        Enum.map(id_list, fn id -> GenServer.stop(id, :normal, 3000) end)
        Logger.debug("end subscribe")
        {:ok, "stop process"}
    end

    def stop_subscribe(sub_id_list) do
        Logger.debug("start stop subscribe")
        Enum.map(sub_id_list, fn id -> GenServer.cast(id, :stop_loop) end)
        Logger.debug("end loop")
        {:ok, "stop subscribe"}
    end

    def publish(id_list, data) do
        n = length(id_list)
        Logger.debug(n)
        pubmsg_list = Rclex.initialize_msgs(n, :string)
        Enum.map(0..(n - 1), fn index ->
                  Rclex.setdata(Enum.at(pubmsg_list, index), data, :string)
                end)
        Enum.map(0..(n - 1), fn index ->
            GenServer.cast(Enum.at(id_list, index), {:publish, Enum.at(pubmsg_list, index)})
        end)
    end
    
    def handle_cast({:subscribe, {id, msg}}, state) do
        GenServer.cast(id, {:execute, msg})
        {:noreply, state}
    end

    def handle_call({:sub_start_link, sub, context, call_back},_from, state) do
        {:ok, pid} = Rclex.Subscriber.start_link(sub, context, call_back)
        {:reply, pid, state}
    end

    def handle_info({_, pid, reason}, state) do
        Logger.debug(reason)
        {:noreply, state}
    end
end