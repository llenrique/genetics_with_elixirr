defmodule Toolbox.Mutation do
  alias Types.Chromosome
  use Bitwise


  @spec simple_shuffle(Chromosome.t()) :: Chromosome.t()
  def simple_shuffle(chromosome) do
    %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
  end

  @spec flip(Chromosome.t()) :: Chromosome.t()
  def flip(chromosome) do
    genes =
      chromosome.genes
      |> Enum.map(&(&1^^^1))

    %Chromosome{chromosome | genes: genes}
  end

  @spec soft_flip(Chromosome.t()) :: Chromosome.t()
  def soft_flip(chromosome) do
    genes = Enum.map(chromosome.genes, fn gen ->
      case Enum.random(0..1) do
        1 -> bxor(gen, 1)
        0 -> gen
      end
    end)

    %Chromosome{chromosome | genes: genes}
  end

  def gaussian(chromosome) do
    mu = Enum.sum(chromosome.genes) / length(chromosome.genes)

    sigma =
      chromosome.genes
      |> Enum.map(fn gen -> (mu - gen) * (mu - gen) end)
      |> Enum.sum()
      |> Kernel./(length(chromosome.genes))

    genes = Enum.map(chromosome.genes, fn _ -> :rand.normal(mu, sigma) end)

    %Chromosome{chromosome | genes: genes}
  end
end
