defmodule ThemaVerbiProper do
  use ExUnit.Case
  use PropCheck
  doctest ThemaVerbi

  ##
  ## Properties
  #
  property "description of what the property does" do
    forall term <- my_type() do
      IO.inspect(term, label: "term")
      boolean(term)
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
end
