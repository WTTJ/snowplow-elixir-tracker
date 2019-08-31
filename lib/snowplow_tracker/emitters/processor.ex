defmodule SnowplowTracker.Emitters.Processor do
  @moduledoc """
  Processor module implementing the functions required for the bulk APIj
  """
  alias :ets, as: Ets
  alias SnowplowTracker.{Constants, Errors, Payload, Request, Response}

  @table Application.get_env(:snowplow_tracker, :table_name)
  @lock "lock"
  @chunk_size 100
  @headers [Accept: Constants.post_content_type()]
  @options Application.get_env(:snowplow_tracker, :default_options) || []

  # Public API
  def send() do
    with [{_name, state}] <- acquire_lock(),
         state == true do
      {keys, payloads, urls} = Ets.match(@table, {:"$1", :"$2", :"$3"})
      url = List.first(urls)

      payloads
      |> Enum.chunk_every(@chunk_size)
      |> Enum.map(&create_payload/1)
      |> Enum.map(&send_request(&1, url))

      Enum.each(keys, fn key -> delete_key(key) end)
      delete_key(@lock)
    else
      {:error, error} ->
        raise Errors.LockError, Kernel.inspect(error)
    end
  end

  def insert(payload, url) do
    eid = Map.get(payload, :eid)

    Ets.insert(
      @table,
      {eid, payload, url}
    )

    {:ok, "Insert successful"}
  end

  # Private API
  defp create_payload(payloads) do
    events =
      Enum.map(payloads, fn payload ->
        Payload.get(payload)
      end)

    {:ok, encoded_payload} =
      Jason.encode(%{
        schema: Constants.schema_payload_data(),
        data: events
      })

    encoded_payload
  end

  defp send_request(payload_chunk, url) do
    with {:ok, response} <- Request.post(url, payload_chunk, @headers, @options),
         {:ok, body} <- Response.parse(response) do
      {:ok, body}
    else
      {:error, error} ->
        raise Errors.ApiError, Kernel.inspect(error)
    end
  end

  defp acquire_lock() do
    Ets.lookup(@table, @lock)
  end

  defp delete_key(key) do
    Ets.delete(@table, key)
  end
end
