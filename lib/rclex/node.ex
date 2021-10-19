defmodule Rclex.Node do
    alias Rclex.Nifs
    require Rclex.Macros
    require Logger
    use GenServer, restart: :transient

@moduledoc """
  T.B.A
"""

    def start_link({node, node_name}) do
        GenServer.start_link(__MODULE__, {node, node_name}, name: {:global, node_name})
    end

    def start_link(node, node_name, node_namespace) do
        name = node_namespace ++ '/' ++ node_name
        GenServer.start_link(__MODULE__, {node, name}, name: {:global, name})
    end

    def init({node, name}) do
        {:ok, {node, name, %{}}}
    end

    @doc """
        指定したnodeとtopicのsubscriberプロセスを作成
        
    """
    def create_single_subscriber(node_identifier, topic_name) do
        GenServer.call({:global, node_identifier}, {:create_subscriber, node_identifier, topic_name})
    end

    def create_subscribers(node_identifier_list, topic_name) do
        sub_identifier_list = 
            Enum.map(node_identifier_list, fn node_identifier -> GenServer.call({:global, node_identifier}, {:create_subscriber, node_identifier, topic_name}) end)
            |> Enum.map(fn {:ok, sub_identifier} -> sub_identifier end)
            
        {:ok, sub_identifier_list}
    end

    def create_single_publisher(node_identifier, topic_name) do
        GenServer.call({:global, node_identifier}, {:create_publisher, node_identifier, topic_name})
    end

    def create_publishers(node_identifier_list, topic_name) do
        pub_identifier_list =  
            Enum.map(node_identifier_list, fn node_identifier -> GenServer.call({:global, node_identifier}, {:create_publisher, node_identifier, topic_name}) end)
            |> Enum.map(fn {:ok, pub_identifier} -> pub_identifier end)
        {:ok, pub_identifier_list}
    end

    def finish_job({node_identifier, topic_name, role}) do
        :ok = GenServer.call({:global, node_identifier}, {:finish_job, topic_name, role})
    end

    def handle_call({:create_subscriber, node_identifier, topic_name}, _, {node, name, supervisor_ids}) do
        subscriber = Nifs.rcl_get_zero_initialized_subscription()
        sub_op = Nifs.rcl_subscription_get_default_options()
        sub = Nifs.rcl_subscription_init(subscriber, node, topic_name, sub_op)
        children = [
            {Rclex.Subscriber, {sub, node_identifier ++ '/' ++ topic_name}}
        ]
        opts = [strategy: :one_for_one]
        {:ok, id} = Supervisor.start_link(children, opts)
        # TODO: has_keyで見る
        new_supervisor_ids = Map.put_new(supervisor_ids, {:sub, topic_name}, id)
        {:reply, {:ok, {node_identifier, topic_name, :sub}}, {node, name, new_supervisor_ids}}
    end

    def handle_call({:create_publisher, node_identifier, topic_name}, _, {node, name, supervisor_ids}) do
        publisher = Nifs.rcl_get_zero_initialized_publisher()
        pub_op = Nifs.rcl_publisher_get_default_options()
        pub = Nifs.rcl_publisher_init(publisher, node, topic_name, pub_op)
        children = [
            {Rclex.Publisher, {pub, node_identifier ++ '/' ++ topic_name}}
        ]
        opts = [strategy: :one_for_one]
        {:ok, id} = Supervisor.start_link(children, opts)
        new_supervisor_ids = Map.put_new(supervisor_ids, {:pub, topic_name}, id)
        Logger.debug(node_identifier ++ '/' ++ topic_name)
        {:reply, {:ok, {node_identifier, topic_name, :pub}}, {node, name, new_supervisor_ids}}
    end

    def handle_call({:finish_job, topic_name, role}, _from, {node, name, supervisor_ids}) do
        {:ok, supervisor_id} = Map.fetch(supervisor_ids, {role, topic_name})

        key = name ++ '/' ++ topic_name

        {:ok, text} = GenServer.call({:global, key}, {:finish, node})

        Logger.debug(text ++ key)

        Supervisor.stop(supervisor_id)

        new_supervisor_ids = Map.delete(supervisor_ids, topic_name)

        {:reply, :ok, {node, name, new_supervisor_ids}}
    end

    def handle_call({:finish_subscriber, topic_name}, _from, {node, name, supervisor_ids}) do
        {:ok, supervisor_id} = Map.fetch(supervisor_ids, {:sub, topic_name})

        sub_key = name ++ '/' ++ topic_name

        :ok = GenServer.call({:global, sub_key}, {:finish_subscriber, node})

        Supervisor.stop(supervisor_id)

        new_supervisor_ids = Map.delete(supervisor_ids, topic_name)

        {:reply, :ok, {node, name, new_supervisor_ids}}
    end

    def handle_call(:finish_node, _from, {node, name, supervisor_ids}) do
        Nifs.rcl_node_fini(node)

        #TODO nodeに紐付いているpub,subをきちんと終了させる

        {:reply, :ok, {node, name, supervisor_ids}}
    end
end