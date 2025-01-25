# This is my solution for the "Hide a message in a deck of playing cards" Kata.
# It took me almost 12 hours to solve this, since I'm a complete beginner when
# it comes to Elixir as of right now. This challenge/Kata can be found at:
# https://www.codewars.com/kata/59b9a92a6236547247000110/

defmodule PlayingCards do

  @ranks ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"]
  @suits ["C", "D", "H", "S"]
  @characters [" "] ++ Enum.map(?A..?Z, &<<&1::utf8>>)

  @char_to_digit Map.new(Enum.with_index(@characters))
  @digit_to_char Map.new(Enum.with_index(@characters) |> Enum.map(fn {char, idx} -> {idx, char} end))

  def generate_deck do
    for suit <- @suits, rank <- @ranks, do: "#{rank}#{suit}"
  end

  def factorial(0), do: 1
  def factorial(n), do: n * factorial(n - 1)

  def compute_factorial_digits(0, 0), do: [0]
  def compute_factorial_digits(_, -1), do: []
  def compute_factorial_digits(number, n) do
    factorial = factorial(n)
    digit = div(number, factorial)
    remainder = rem(number, factorial)
    [digit | compute_factorial_digits(remainder, n - 1)]
  end

  def message_to_number(message) do
    message
    |> String.graphemes()
    |> Enum.reduce_while(0, fn char, acc ->
      case Map.get(@char_to_digit, char) do
        nil -> 
          IO.inspect(char, label: "Invalid Character")
          {:halt, :error}
        digit -> {:cont, acc * 27 + digit}
      end
    end)
  end

  def number_to_permutation(number) do
    deck = generate_deck()
    factorial_digits = compute_factorial_digits(number, length(deck) - 1)
    IO.inspect(factorial_digits, label: "Factorial Digits")
    generate_permutation(deck, factorial_digits)
  end

  def generate_permutation(deck, digits) do
    Enum.reduce(digits, {deck, []}, fn digit, {remaining_deck, permutation} ->
      IO.inspect({digit, remaining_deck}, label: "Digit and Remaining Deck")
      case List.pop_at(remaining_deck, digit) do
        {nil, _} -> 
          IO.inspect(digit, label: "Invalid Digit")
          {remaining_deck, permutation}
        {item, new_deck} -> {new_deck, [item | permutation]}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  def encode(message) do
    case message_to_number(message) do
      :error -> nil
      number -> number_to_permutation(number)
    end
  end

  def decode(deck) do
    number = permutation_to_number(deck)
    number_to_message(number)
  end

  def number_to_message(0), do: ""
  def number_to_message(number) do
    digit = rem(number, 27)
    char = Map.get(@digit_to_char, digit, " ")
    number_to_message(div(number, 27)) <> char
  end

  def permutation_to_number(permuted_deck) do
    standard_deck = generate_deck()
    permutation_to_number(permuted_deck, standard_deck, 0, length(standard_deck) - 1)
  end

  def permutation_to_number([], _deck, number, _), do: number

  def permutation_to_number([card | rest], deck, number, n) do
    index = Enum.find_index(deck, &(&1 == card))
    factorial = factorial(n)
    new_number = number + index * factorial
    new_deck = List.delete_at(deck, index)
    permutation_to_number(rest, new_deck, new_number, n - 1)
  end

end
