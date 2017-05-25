defmodule HelloWorld.MainWorker do
  use AMQP
  alias HelloWorld.Worker.{
    PostWorker, TestWorker
  }


  def assign_job(chan, tag, _redelivered, payload) do
    try do
      case Poison.decode payload do
       {:ok, obj} ->
         # IO.puts "MAIN WORKER #{inspect obj}"
         case obj["action"] do
          #  "worker:test_worker"                -> TestWorker.log(obj)
           "group:update_post"                 -> PostWorker.update_post(obj)
           nil                                 -> requeue_uncaught(chan, obj)
           _                                   -> requeue_uncaught(chan, obj)
         end
         Basic.ack chan, tag
       {:error, _} ->
         Basic.reject chan, tag, requeue: false
     end
     rescue
       exception ->
         Basic.publish chan, "", "wait_min_10", payload, persistent: true
         Basic.ack chan, tag
         reraise exception, System.stacktrace
    end
  end

  # defp handle_nil_action(chan, obj) do
  #   case obj["field"] do
  #     "conversations" -> InboxWorker.update_inbox(Map.merge(obj, %{"action" => "pages:update_inbox"}))
  #     "feed" -> handle_feed_field(chan, obj)
  #     "videos" -> IO.inspect obj
  #     "live_videos" -> IO.inspect obj
  #     _ -> requeue_uncaught(chan, obj)
  #   end
  # end

  defp requeue_uncaught(chan, task) do
    message = Poison.encode! task
    Basic.publish chan, "", "task_pool_uncaught", message, persistent: true
  end
end
