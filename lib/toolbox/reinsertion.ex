defmodule Toolbox.Reinsertion do
  def pure(_parents, offspring, _left_overs, _opts), do: offspring

  def elitist(parents, offspring, left_overs, opts) do
    survival_rate = Keyword.get(opts, :survival_rate, 0.2)

    parents =
			parents
			|> Enum.reduce([], fn par, acc ->
				acc ++ Tuple.to_list(par)
			end)

    old = parents ++ left_overs


    n = floor(length(old) * survival_rate)

    survivors =
      old
      |> Enum.sort_by(& &1.fitness, &>=/2)
      |> Enum.take(n)

    offspring ++ survivors
  end

  def uniform(parents, offspring, left_overs, opts) do
    survival_rate = Keyword.get(opts, :survival_rate, 0.2)

    parents =
			parents
			|> Enum.reduce([], fn par, acc ->
				acc ++ Tuple.to_list(par)
			end)

    old = parents ++ left_overs
    n = floor(length(old) * survival_rate)

    survivors = Enum.take_random(old, n)

    offspring ++ survivors
  end
end
