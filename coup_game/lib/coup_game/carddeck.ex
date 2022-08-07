defmodule CoupGame.Carddeck do
  alias CoupGame.Card

  @spec generate_card({atom(), integer()}) :: Card.t()
  def generate_card({:card_duke, id}) do
    %Card{type: :card_duke, uuid: id, title: "Duke", file: "duke",
          description: "Take 3 🪙 coins from the treasury. Block someone from taking foreign aid."}
  end

  def generate_card({:card_assasin, id}) do
    %Card{type: :card_assasin, uuid: id,  title: "Assasin", file: "assasin",
          description: "Pay 3 🪙 coins and try to assasinate another player's character."}
  end

  def generate_card({:card_contessa, id}) do
    %Card{type: :card_assasin, uuid: id, title: "Contessa", file: "contessa",
          description: "Block an assassination attempt against yourself."}
  end

  def generate_card({:card_captain, id}) do
    %Card{type: :card_assasin, uuid: id, title: "Captain", file: "captain",
          description: "Take 2 🪙 coins from another player or block someone from stealing coins from you."}
  end

  def generate_card({:card_ambassador, id}) do
    %Card{type: :card_assasin, uuid: id, title: "Ambassador", file: "ambassador",
          description: "Draw 2 character cards ❏❏ from the Court (the deck), choose which (if any) to exchange with your face-down characters, then return 2. Block someone from stealing coins from you."}
  end

  def get_card_types() do
    [:card_duke, :card_assasin, :card_contessa, :card_captain, :card_ambassador]
  end

  def expand_cards(cards) do
    cards |> Enum.map(&generate_card/1)
  end

  @doc """
  Generates a deck for the game
  """
  def generate_carddeck() do
    all_card_types = get_card_types()
    all_card_types
      |> Enum.map(fn x -> List.duplicate(x, 3) end)
      |> List.flatten()
      |> Enum.shuffle()
      |> Enum.with_index()
  end

  @doc """
  Deal cards between players and court
  """
  def deal_deck(player_count) do
    {player_cards, court_deck} = generate_carddeck() |> Enum.split(player_count * 2)
    player_cards = player_cards |> Enum.chunk_every(2)
    {court_deck, player_cards}
  end

end
