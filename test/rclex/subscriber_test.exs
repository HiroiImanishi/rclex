defmodule Rclex.SubscriberTest do
  use ExUnit.Case

  @moduletag capture_log: true

  import Rclex.TestUtils,
    only: [
      get_initialized_context: 0,
      get_initialized_no_namespace_node: 2,
      get_initialized_subscription: 3
    ]

  alias Rclex.Subscriber

  setup do
    msg_type = 'StdMsgs.Msg.String'
    node_id = 'node'
    topic = 'topic'

    context = get_initialized_context()
    node = get_initialized_no_namespace_node(context, node_id)

    subscription = get_initialized_subscription(node, topic, msg_type)

    subscriber_id = "#{node_id}/#{topic}/sub"

    pid = start_supervised!({Rclex.Subscriber, {subscription, msg_type, subscriber_id}})

    %{
      id_tuple: {node_id, topic, :sub},
      context: Rclex.get_initialized_context(),
      callback: fn _ -> nil end,
      node: node,
      pid: pid
    }
  end

  describe "start_subscribing/3" do
    test "call to element, return :ok", %{
      id_tuple: id_tuple,
      context: context,
      callback: callback
    } do
      assert :ok = Subscriber.start_subscribing(id_tuple, context, callback)
    end

    test "call to list, return :ok", %{id_tuple: id_tuple, context: context, callback: callback} do
      assert [:ok] = Subscriber.start_subscribing([id_tuple], context, callback)
    end
  end

  describe "stop_subscribing/1" do
    test "call to element, return :ok", %{
      id_tuple: id_tuple,
      context: context,
      callback: callback
    } do
      :ok = Subscriber.start_subscribing(id_tuple, context, callback)
      assert :ok = Subscriber.stop_subscribing(id_tuple)
    end

    test "call to list, return :ok", %{
      id_tuple: id_tuple,
      context: context,
      callback: callback
    } do
      id_tuple_list = [id_tuple]
      [:ok] = Subscriber.start_subscribing(id_tuple_list, context, callback)
      assert [:ok] = Subscriber.stop_subscribing(id_tuple_list)
    end

    test "stop not started subscribing, return :error", %{id_tuple: id_tuple} do
      assert :error = Subscriber.stop_subscribing(id_tuple)
    end

    test "stop not started subscribing, return [:error]", %{id_tuple: id_tuple} do
      assert [:error] = Subscriber.stop_subscribing([id_tuple])
    end
  end

  describe "handle_call({:finish, node}, ...)" do
    test "return ok tuple", %{node: node, pid: pid} do
      assert {:ok, 'subscriber finished: '} = GenServer.call(pid, {:finish, node})
    end
  end

  describe "handle_call({:finish_subscriber, node}, ...)" do
    test "return ok tuple", %{node: node, pid: pid} do
      assert :ok = GenServer.call(pid, {:finish_subscriber, node})
    end
  end
end
