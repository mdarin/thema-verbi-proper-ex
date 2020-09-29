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
      #IO.inspect(to_string(v), label: "freq")
      true == true
    end
  end

  property "To avoid having to micromanage all these calls to make sure everything is preserved" do
    # To avoid having to micromanage all these calls to make sure everything is preserved, you can instead use the ?SIZED(VarName, Expression) macro,
    # which introduces the variable VarName into the scope of Expression, bound to the internal size value for the current execution.
    # This size value changes with every test, so what we do with the macro is change its scale, rather than replacing it wholesale.
    forall v <- sized(s, resize(s * 35, utf8() )) do
      #IO.inspect(v, label: "sized+resize")
      true == true
    end
  end

  # make verbose for metrics
  property "The collect(Value, PropertyResult) function allows you to gather the values of one specific metric per test", [:verbose] do
    # The collect(Value, PropertyResult) function allows you to gather the values of one specific metric per test and
    # build stats out of all the runs that happened for a property.
    # The `metric` argument is the metric from which you want to build statistics—here it’s the binary’s length and
    # the `test` argument is the result of the property it should return boolean true or false value.
    forall bin <- binary() do
          #            test          metric
          #collect(is_binary(bin), byte_size(bin))
          # group the values by a given range (by groups of 10)
          collect(is_binary(bin), to_range(10, byte_size(bin)) )
      end
  end

  # make verbose for metrics
  property "aggregate() is similar to collect()", [:verbose] do
    # The aggregate() is similar to collect(), with the exception it can take a list of categories to store.
    # The `metric` argument is the metric from which you want to build statistics—here it’s the binary’s length and
    # the `test` argument is the result of the property it should return boolean true or false value.
    suits = [:club, :diamond, :heart, :spade]
    forall hand <- vector(5, {oneof(suits), choose(1, 13)}) do
      # always pass
      #         test   metric
      aggregate(true,  hand)
    end
  end

  # make verbose for metrics
  property "fake escaping test showcasing aggregation", [:verbose] do
    # Another interesting case for aggregation is one where we might want to gather metrics on various data categories.
    forall str <- utf8() do
      aggregate(escape(str), classes(str))
    end
  end

  ##
  ## Helpers
  #
  defp boolean(_) do
    true
  end

  @doc """
  The to_range/2 function places a value M into a given bucket of size N.
  """
  def to_range(m, n) do
    base = div(n, m)
    {base * m, (base + 1) * m}
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

  # this is a check we don't care about
  defp escape(_), do: true

  defp classes(str) do
    l = letters(str)
    n = numbers(str)
    p = punctuation(str)
    o = String.length(str) - (l+n+p)
    [{:letters, to_range(5, l)}, {:numbers, to_range(5, n)}, {:punctuation, to_range(5, p)}, {:others, to_range(5, o)}]
  end

  defp letters(str) do
    is_letter = fn c -> (c >= ?a && c <= ?z) || (c >= ?A && c <= ?Z) end
    length(for <<c::utf8 <- str>>, is_letter.(c), do: 1)
  end

  defp numbers(str) do
    is_num = fn c -> c >= ?0 && c <= ?9 end
    length(for <<c::utf8 <- str>>, is_num.(c), do: 1)
  end

  defp punctuation(str) do
    is_punctuation = fn c -> c in '.,;:\'"-' end
    length(for <<c::utf8 <- str>>, is_punctuation.(c), do: 1)
  end
end
