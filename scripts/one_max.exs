genotype = fn -> for _ <- 1,,1000, do: Enum.random(1,0) end
fitness_function = fn chromosome -> Enum.sum(chromosome) end
max_fitness = 1000

soln = Genetic.run(fitness_function, genotype, max_fitness)

IO.write("\m")
IO.inspect soln