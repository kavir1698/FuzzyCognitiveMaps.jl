"""
    create_fcm(concepts::Vector{String}, weights::Matrix{Float64},
               activation::Function, initial_state::Vector{Float64};
               track_history::Bool=false,
               external_concepts::Vector{Bool}=falses(length(concepts)))

Create a new Fuzzy Cognitive Map (FCM) with the specified parameters.

# Arguments
- `concepts::Vector{String}`: Names of the concepts in the FCM
- `weights::Matrix{Float64}`: Adjacency matrix representing the causal weights between concepts
- `activation::Function`: Activation function to be applied during state updates
- `initial_state::Vector{Float64}`: Initial activation values for each concept
- `track_history::Bool=false`: Whether to track state history during updates
- `external_concepts::Vector{Bool}`: Indicates which concepts are external (fixed during updates)

# Returns
- `FuzzyCognitiveMap`: A new FCM instance initialized with the given parameters
"""
function create_fcm(concepts::Vector{String}, weights::Matrix{Float64},
                   activation::Function, initial_state::Vector{Float64};
                   track_history::Bool=false,
                   external_concepts::Vector{Bool}=Vector{Bool}(falses(length(concepts))))

    validate_fcm_inputs(concepts, weights, initial_state)

    concept_indices = Dict(concept => i for (i, concept) in enumerate(concepts))
    weights_f16 = Float16.(weights)
    initial_state_f16 = Float16.(initial_state)
    history = track_history ? [copy(initial_state_f16)] : Vector{Float16}[]

    FuzzyCognitiveMap(concepts, concept_indices, weights_f16, activation,
                      initial_state_f16, history, track_history, external_concepts)
end

"""
    update!(fcm::FuzzyCognitiveMap)

Perform a single state update step on the `fcm`.

Updates the state of non-external concepts using the formula:
`new_state = activation(state * weights)`

If track_history is enabled, the new state is added to the history.

# Arguments
- `fcm::FuzzyCognitiveMap`: The FCM to update
"""
function update!(fcm::FuzzyCognitiveMap)
    new_state = fcm.activation.((fcm.state' * fcm.weights)')
    fcm.state .= ifelse.(fcm.external_concepts, fcm.state, new_state)
    fcm.track_history && push!(fcm.history, copy(fcm.state))
end

"""
    run!(fcm::FuzzyCognitiveMap, iterations::Int; tolerance::Float64=1e-6)

Run the FCM simulation for a specified number of iterations or until convergence.

# Arguments
- `fcm::FuzzyCognitiveMap`: The FCM to simulate
- `iterations::Int`: Maximum number of iterations to run
- `tolerance::Float64=1e-6`: Convergence threshold for state changes

# Returns
- Vector{Float16}: The final state of the FCM after simulation

The simulation stops either when the maximum number of iterations is reached
or when the change in state (measured by L2 norm) falls below the tolerance.
"""
function run!(fcm::FuzzyCognitiveMap, iterations::Int; tolerance::Float64=1e-6)
    for _ in 1:iterations
        old_state = copy(fcm.state)
        update!(fcm)
        norm(fcm.state - old_state) < tolerance && break
    end
    return fcm.state
end
