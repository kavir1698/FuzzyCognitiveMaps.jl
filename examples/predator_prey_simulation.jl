using FuzzyCognitiveMaps
using Random

# Agent structure
mutable struct Agent
    position::Tuple{Float64, Float64}
    mind::FuzzyCognitiveMaps.FuzzyCognitiveMap
    energy::Float64
end

# World structure
mutable struct World
    size::Tuple{Int, Int}
    predators::Vector{Agent}
    prey::Vector{Agent}
end

function create_predator_mind()
  concepts = ["hunger", "prey_presence", "fear", "attack_motivation", "flee_motivation"]

  # Define relationships between concepts
  weights = Float64[
    # hunger prey  fear  attack flee
    0.0 0.0 0.2 0.6 -0.2;  # hunger affects fear(+), attack(+), flee(-)
    0.0 0.0 0.3 0.7 0.0;  # prey affects fear(+), attack(+)
    0.0 -0.2 0.0 -0.8 0.9;  # fear reduces prey detection(-), attack(-), increases flee(+)
    0.0 0.0 -0.3 0.0 -0.5;  # attack reduces fear(-), flee(-)
    0.0 0.0 0.2 -0.4 0.0   # flee increases fear(+), reduces attack(-)
  ]

  # Initial state: moderately hungry, no prey, no fear
  initial_state = [0.5, 0.0, 0.0, 0.0, 0.0]

  return create_fcm(concepts, weights, sigmoid, initial_state, track_history=true)
end


# Create prey mind (simpler than predator)
function create_prey_mind()
    concepts = ["predator_presence", "energy", "fear", "escape_motivation", "forage_motivation"]
    weights = Float64[
        # pred  energy fear  escape forage
        0.0    0.0    0.8    0.9   -0.5;  # predator presence
        0.0    0.0   -0.2   -0.3    0.8;  # energy
        0.0    0.0    0.0    0.7   -0.6;  # fear
        0.0   -0.2    0.0    0.0   -0.8;  # escape motivation
        0.0    0.3   -0.3   -0.4    0.0   # forage motivation
    ]
    initial_state = [0.0, 0.5, 0.0, 0.0, 0.5]
    return create_fcm(concepts, weights, sigmoid, initial_state)
end

# Create a simple world
function create_world(size::Tuple{Int, Int}, n_predators::Int, n_prey::Int)
    predators = [Agent((rand()*size[1], rand()*size[2]),
                      create_predator_mind(),
                      true) for _ in 1:n_predators]

    prey = [Agent((rand()*size[1], rand()*size[2]),
                 create_prey_mind(),
                 true) for _ in 1:n_prey]

    return World(size, predators, prey)
end

# Calculate distance between two positions
distance(p1::Tuple{Float64, Float64}, p2::Tuple{Float64, Float64}) =
    sqrt((p1[1] - p2[1])^2 + (p1[2] - p2[2])^2)

# Update agent's mind based on environment
function update_mind!(agent::Agent, world::World, is_predator::Bool)
    if is_predator
        # Find nearest prey
        nearest_prey_dist = minimum(distance(agent.position, prey.position)
                                  for prey in world.prey; init=Inf)
        set_state!(agent.mind, "prey_presence", max(0, 1 - nearest_prey_dist/5))
        set_state!(agent.mind, "hunger", max(0, 1 - agent.energy))
    else
        # Find nearest predator
        nearest_pred_dist = minimum(distance(agent.position, pred.position)
                                  for pred in world.predators; init=Inf)
        set_state!(agent.mind, "predator_presence", max(0, 1 - nearest_pred_dist/5))
        set_state!(agent.mind, "energy", agent.energy)
    end

    update!(agent.mind)
end

# Move agent based on mind state
function move_agent!(agent::Agent, world::World, is_predator::Bool)
    if is_predator
        attack_motivation = get_concept_value(agent.mind, "attack_motivation")
        flee_motivation = get_concept_value(agent.mind, "flee_motivation")

        # Simple movement based on motivations
        dx = (attack_motivation - flee_motivation) * 0.1 * randn()
        dy = (attack_motivation - flee_motivation) * 0.1 * randn()
    else
        escape_motivation = get_concept_value(agent.mind, "escape_motivation")
        forage_motivation = get_concept_value(agent.mind, "forage_motivation")

        dx = (forage_motivation - escape_motivation) * 0.1 * randn()
        dy = (forage_motivation - escape_motivation) * 0.1 * randn()
    end

    # Update position with boundary checking
    agent.position = (
        clamp(agent.position[1] + dx, 0, world.size[1]),
        clamp(agent.position[2] + dy, 0, world.size[2])
    )

    # Decrease energy
    agent.energy = max(0.0, agent.energy - 0.01)
end

# Main simulation step
function simulation_step!(world::World)
    # Update and move predators
    for predator in world.predators
        update_mind!(predator, world, true)
        move_agent!(predator, world, true)
    end

    # Update and move prey
    for prey in world.prey
        update_mind!(prey, world, false)
        move_agent!(prey, world, false)
    end

    # Handle predation
    for predator in world.predators
        for (i, prey) in enumerate(world.prey)
            if distance(predator.position, prey.position) < 0.5
                # Successful predation
                predator.energy = min(1.0, predator.energy + 0.3)
                deleteat!(world.prey, i)
                break
            end
        end
    end
end

# Run simulation
function run_simulation()
    world = create_world((10, 10), 2, 10)  # 10x10 world, 2 predators, 10 prey

    for step in 1:100
        println("Step $step: $(length(world.predators)) predators, $(length(world.prey)) prey")
        simulation_step!(world)

        # Optional: Add new prey occasionally
        if rand() < 0.1
            push!(world.prey, Agent((rand()*world.size[1], rand()*world.size[2]),
                                  create_prey_mind(),
                                  1.0))
        end

        sleep(0.1)  # Slow down simulation for visualization
    end
end

# Run the simulation
run_simulation()
