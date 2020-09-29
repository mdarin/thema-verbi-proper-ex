defmodule ThemaVerbiProper do
  use ExUnit.Case
  use PropCheck
  doctest ThemaVerbi

  ##
  ## Properties
  #
  property "description of what the property does" do
    forall term <- my_type() do
      boolean(term)
    end
  end

  ## Default Generators. Here are a few of the important ones

  property "Any Erlang term" do
    # any(), term()
    forall t <- {any(), term()} do
      #IO.inspect(t, label: "any term")
      true == true
    end
  end

  property "Any integer between Min and Max" do
    # choose(Min, Max), range(Min, Max)
    forall v <- range(0, 99) do
      #IO.inspect(v, label: "value from range")
      true == true
    end
  end

  property "A list where all entries match a generator from the list of arguments" do
    # fixed_list([Type])
    forall v <- fixed_list([float(), boolean(), byte(), atom()]) do
      #IO.inspect(v, label: "entries as generators")
      true == true
    end
  end

  property "A float or integer" do
    # integer() An integer, number() A float or integer
    forall v <- number() do
      #IO.inspect(v, label: "float or integer")
      true == true
    end
  end

  property "Constrains a binary or a list generator into not being empty" do
    # non_empty(Gen)
    forall v <- non_empty({integer(), float()}) do
      #IO.inspect(v, label: "non empty")
      true == true
    end
  end

  property "A tuple of random terms" do
    # ￼tuple()
    forall v <- tuple() do
      #IO.inspect(v, label: "arbitraty typel")
      true == true
    end
  end

  @vlen 3
  property "A literal tuple with types in it" do
    # {T1, T2, ...}
    forall v <- {integer(), float(), vector(@vlen, number())} do
      #IO.inspect(v, label: "typle with types")
      true == true
    end
  end

  property "A list of length Len of type Type" do
    # vector(Len, Type)
    forall v <- vector(@vlen, number()) do
      #IO.inspect(v, label: "vector")
      true == true
    end
  end

  property "Generates to utf8-encoded text as binary data structure" do
    # utf8()
    forall v <- utf8() do
      #IO.inspect(v, label: "utf str")
      true == true
    end
  end

  property "The value created by the generator of one of those in Types, also union(Types) and elements(Types)" do
    # oneof(Types) .
    forall v <- oneof([float(), number(), vector(@vlen, integer())]) do
      #IO.inspect(v, label: "one of")
      true == true
    end
  end

  property "Frequency of one of those in the second tuple element, with a probability similar to the valuie N" do
    # frequency([{N, The value matching the generator Type}]) of one of those in the second tuple element, with a probability similar to the value N.
    forall v <- list(
      frequency([
        {80, range(?a, ?z)},
        {10, ?\s},
        {1, ?\n},
        {1, oneof([?., ?-, ?!, ??, ?,])}, {1, range(?0, ?9)}
      ])
    ) do
      IO.inspect(to_string(v), label: "freq")
      true == true
    end
  end

  ##
  ## Helpers
  #
  defp boolean(_) do
    true
  end

  ##
  ## Generators
  #
  def my_type() do
    term()
  end

  # def text_like() do let l <-
  #   list(
  #     frequency([
  #       {80, range(?a, ?z)},
  #       {10, ?\s},
  #       {1, ?\n},
  #       {1, oneof([?., ?-, ?!, ??, ?,])}, {1, range(?0, ?9)}
  #     ])
  #   ) do
  #       to_string(l)
  #   end
  # end


  ##
  ## Internals
  #

end
