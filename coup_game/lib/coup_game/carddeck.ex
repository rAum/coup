defmodule CoupGame.Carddeck do
  alias CoupGame.Card


  @spec generate_card({atom(), integer()}) :: Card.t()
  def generate_card({:card_duke, id}) do
    %Card{type: :card_duke, uuid: id, title: "Duke",
          description: "Take 3 coins from the treasury. Block someone from taking foreign aid."}
  end

  def generate_card({:card_assasin, id}) do
    %Card{type: :card_assasin, uuid: id,  title: "Assasin",
          description: "Pay 3 coins and try to assasinate another player's character."}
  end

  def generate_card({:card_contessa, id}) do
    %Card{type: :card_assasin, uuid: id, title: "Contessa",
          description: "Block an assassination attempt against yourself."}
  end

  def generate_card({:card_captain, id}) do
    %Card{type: :card_assasin, uuid: id, title: "Captain",
          description: "Take 2 coins from another player or block someone from stealing coins from you."}
  end

  def generate_card({:card_ambassador, id}) do
    %Card{type: :card_assasin, uuid: id, title: "Ambassador",
          description: "Draw 2 character cards from the Court (the deck), choose which (if any) to exchange with your face-down characters, then return 2. Block someone from stealing coins from you."}
  end

  def expand_cards(cards) do
    cards |> Enum.map(&generate_card/1)
  end

  @doc """
  Generates a deck for the game
  """
  def generate_carddeck() do
    all_card_types = [:card_duke, :card_assasin, :card_contessa, :card_captain, :card_ambassador]
    all_card_types
      |> Enum.map(fn x -> List.duplicate(x, 3) end)
      |> List.flatten()
      |> Enum.shuffle()
      |> Enum.with_index()
  end

end
