defmodule Toolbox.Mutation do
  alias Types.Chromosome


  @spec simple_shuffle(Chromosome.t(), keyword) :: Chromosome.t()
  def simple_shuffle(chromosome, opts \\ []) do
    mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)
    if :rand.uniform() < mutation_rate do
      %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
    else
      chromosome
    end
  end

end
