defmodule SocialWeb.Consumer do
  use GenServer
  use AMQP
  alias SocialWeb.{ MainWorker }

  @queue          "task_pool"
  @uncaught_queue "#{@queue}_uncaught"
  @error_queue    "#{@queue}_error"

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_otps) do
    # username = System.get_env("R_USERNAME") || "social_web"
    # password = System.get_env("R_PASSWORD") || "social_web"
    # host = System.get_env("R_HOST") || "localhost"
    # port = System.get_env("R_PORT") || "5673"
    # vhost = System.get_env("R_VHOST") || "v2"

    username = System.get_env("R_USERNAME") || "pancake2"
    password = System.get_env("R_PASSWORD") || "pancake2"
    host = System.get_env("R_HOST") || "localhost"
    port = System.get_env("R_PORT") || "5672"
    vhost = System.get_env("R_VHOST") || "v2"

    amqp_uri = "amqp://#{username}:#{password}@#{host}:#{port}/#{vhost}"
    {:ok, conn} = Connection.open(amqp_uri)
    {:ok, chan} = Channel.open(conn)

    Basic.qos(chan, prefetch_count: 250)
    Queue.declare(chan, @error_queue, durable: true)
    Queue.declare(chan, @uncaught_queue, durable: true)
    Queue.declare(chan, @queue, durable: true,
      arguments: [{"x-dead-letter-exchange", :longstr, ""},
                  {"x-dead-letter-routing-key", :longstr, @error_queue}])

    # Queue.declare(chan, "wait_min_05", durable: true,
    #   arguments: [{"x-dead-letter-exchange", :longstr, ""},
    #               {"x-dead-letter-routing-key", :longstr, @queue},
    #               {"x-message-ttl", :signedint, 300000}])


    # Exchange.fanout(chan, @exchange, durable: true)
    # Queue.bind(chan, @queue, @exchange)

    {:ok, consumer_tag} = Basic.consume(chan, @queue)

    Application.put_env(:social_web, :r_channel, chan)
    # Application.put_env(:social_web, :r_consumer_tag, consumer_tag, persistent: true)
    {:ok, chan}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn -> MainWorker.assign_job(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

end
