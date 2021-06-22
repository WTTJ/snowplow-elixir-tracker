defmodule SnowplowTracker.Events.Helper do
  @moduledoc """
  This module contains the implementations of
  function used to set the default values in the payload.
  """

  @uuid_version 4
  @rfc_4122_variant10 2

  @doc """
  Generate a v4 UUID string to uniquely identify an event
  """
  @spec generate_uuid() :: String.t()
  def generate_uuid do
    <<time_low_mid::48, _version::4, time_high::12, _reserved::2, rest::62>> = :crypto.strong_rand_bytes(16)

    <<time_low_mid::48, @uuid_version::4, time_high::12, @rfc_4122_variant10::2, rest::62>>
    |> Base.encode16(case: :lower)
  end

  @doc """
  Generate unix timestamp in microseconds to identify time of each event.
  """
  @spec generate_timestamp(module()) :: Integer.t()
  def generate_timestamp(module \\ :os) do
    module.system_time(:milli_seconds)
  end

  @doc """
  This function is used to convert a given number to a string. If the number is of type float,
  it is rounded off to 2 places and converted to a string.
  """
  @spec to_string(any()) :: nil | String.t()
  def to_string(nil), do: nil

  def to_string(number) when is_integer(number) do
    Integer.to_string(number)
  end

  def to_string(number) when is_float(number) do
    Float.round(number, 2) |> Float.to_string()
  end

  def to_string(number), do: number
end
