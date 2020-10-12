defmodule StatelessPropertyProper do
  use ExUnit.Case
  use PropCheck
  doctest ThemaVerbi.StatelessProperty

  ##
  ## Properties
  #

  property "overflow", [:verbose, {:numtests, 25}] do
    forall {element, command} <- {element(), command()} do
      IO.inspect(command, label: "command")

      case command do
        :push -> ThemaVerbi.StatelessProperty.push(element)
        _ -> ThemaVerbi.StatelessProperty.pop()
      end

      true
    end
  end

  ##
  ## Helpers
  #

  @doc """
  The to_range/2 function places a value M into a given bucket of size N.
  """
  def to_range(m, n) do
    base = div(n, m)
    {base * m, (base + 1) * m}
  end

  # def ff do
  #   f = &ThemaVerbi.StatelessProperty.push/1
  #   f.(element)
  # end

  ##
  ## Generators
  #

  defp element do
    let sz <- pos_integer() do
      let e <-
            oneof([
              number(),
              sized(s, resize(s + sz, non_empty(list(number()))))
            ]) do
        e
      end
    end
  end

  def command do
    let c <-
          frequency([
            {35, :pop},
            {65, :push}
          ]) do
      c
    end
  end

  ##
  ## Internals
  #
end
