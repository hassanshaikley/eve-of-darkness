defmodule EOD.Server do
  @moduledoc """
  Responsible for orchestrating the back & forth talk
  between clients and delegating to the different
  logic centers of the game
  """
  use GenServer
  alias EOD.Server.ConnManager
  alias EOD.Client
  alias EOD.Socket
  require Logger

  defstruct conn_manager: nil,
            client_manager: nil,
            ref: nil

  def start_link(opts \\ []) do
    ref = opts[:ref] || make_ref()
    GenServer.start_link(__MODULE__, %__MODULE__{ref: ref})
  end

  # GenServer Callbacks

  def init(state=%__MODULE__{}) do
    with \
      {:ok, manager} <- ConnManager.start_link(conn_manager_opts(state)),
      {:ok, client_manager} <- Client.Manager.start_link()
    do
      {:ok, %{state | conn_manager: manager, client_manager: client_manager}}
    end
  end

  # Called when a new client connects from the conn_manager
  def handle_info({{:new_conn, ref}, socket}, %{ref: ref}=state) do
    Client.Manager.start_client(state.client_manager, socket)
    {:noreply, state}
  end

  defp conn_manager_opts(%{ref: ref}) do
    [port: 10300,
     callback: {:send, {:new_conn, ref}, self()},
     wrap: {Socket.TCP.GameSocket, :new, []}]
  end
end
