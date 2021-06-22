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
  def generate_uuid() do
    uuid_hex()
    |> uuid_to_string()
  end

  defp uuid_hex() do
    <<u0::48, _::4, u1::12, _::2, u2::62>> = :crypto.strong_rand_bytes(16)
    <<u0::48, @uuid_version::4, u1::12, @rfc_4122_variant10::2, u2::62>>
  end

  defp uuid_to_string(<<
         a1::4,
         a2::4,
         a3::4,
         a4::4,
         a5::4,
         a6::4,
         a7::4,
         a8::4,
         b1::4,
         b2::4,
         b3::4,
         b4::4,
         c1::4,
         c2::4,
         c3::4,
         c4::4,
         d1::4,
         d2::4,
         d3::4,
         d4::4,
         e1::4,
         e2::4,
         e3::4,
         e4::4,
         e5::4,
         e6::4,
         e7::4,
         e8::4,
         e9::4,
         e10::4,
         e11::4,
         e12::4
       >>) do
    <<e(a1), e(a2), e(a3), e(a4), e(a5), e(a6), e(a7), e(a8), ?-, e(b1), e(b2), e(b3), e(b4), ?-,
      e(c1), e(c2), e(c3), e(c4), ?-, e(d1), e(d2), e(d3), e(d4), ?-, e(e1), e(e2), e(e3), e(e4),
      e(e5), e(e6), e(e7), e(e8), e(e9), e(e10), e(e11), e(e12)>>
  end

  @compile {:inline, e: 1}

  defp e(0), do: ?0
  defp e(1), do: ?1
  defp e(2), do: ?2
  defp e(3), do: ?3
  defp e(4), do: ?4
  defp e(5), do: ?5
  defp e(6), do: ?6
  defp e(7), do: ?7
  defp e(8), do: ?8
  defp e(9), do: ?9
  defp e(10), do: ?a
  defp e(11), do: ?b
  defp e(12), do: ?c
  defp e(13), do: ?d
  defp e(14), do: ?e
  defp e(15), do: ?f

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
