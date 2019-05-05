defmodule EOD.Socket.Inspector.SimpleSubscription do
  defstruct id: nil, forwarder: nil

  def new, do: %__MODULE__{id: make_ref(), forwarder: self()}
end

defimpl EOD.Socket.Inspector.Subscription, for: EOD.Socket.Inspector.SimpleSubscription do

  def notify(%{forwarder: pid}, action, _id, _meta, data) do
    send(pid, {:packet_inspection, action, data})
  end

  def id(%{id: id}), do: id

  def shutting_down(_, _, _) do
  end

  def unsubscribing(_, _, _) do
  end

  def subscribing(_, _, _) do
  end
end
