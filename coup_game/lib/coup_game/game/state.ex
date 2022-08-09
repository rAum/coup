defmodule CoupGame.Game.State do
      @moduledoc """
  A struct representing all states of the game
  """

  @typedoc """
  Represents a single card from the deck
  """
  @type t() :: %__MODULE__{
    public_state: map(),
    player_view: map(),
    priv_state: map(),
    game_stack: list(),
    players: nonempty_list()
  }

  defstruct [:players,
            public_state: %{},
            player_view: %{},
            priv_state: %{},
            game_stack: []]

  @spec new(list) :: :error | %__MODULE__{}
  def new([]), do: :error
  def new([_]), do: :error
  def new(players) when is_list(players) do
    if length(players) <= 7 do
      create_new(players)
    else
      :error
    end
  end
  def new(_), do: :error

  defp create_new(players) do
    n = Enum.count(players)
    {court_deck, player_decks} = CoupGame.Carddeck.deal_deck(n)
    player_hands = Enum.zip([players, player_decks])
    |> Enum.into(%{})

    turn_order = players
                |> Enum.shuffle()
                |> Enum.with_index()
                |> Enum.into(%{})

    public = %{
      coins: Enum.zip([players, Stream.repeatedly(fn -> 2 end)]) |> Enum.into(%{}),
      turn: 0,
      turn_order: turn_order,
    }

    priv = %{
      court: court_deck,
      hands: player_hands,
    }

    %__MODULE__{
      players: players,
      public_state: public,
      priv_state: priv,
    }
  end
end
