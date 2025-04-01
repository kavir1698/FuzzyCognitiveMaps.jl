module Analysis

using Statistics
using LinearAlgebra
using ..FuzzyCognitiveMaps: FuzzyCognitiveMap, run!, set_state!, get_concept_value

export run_scenario, compare_interventions, find_equilibrium_state
export analyze_concept_impact, sensitivity_analysis
export intervention_analysis

"""
    run_scenario(fcm::FuzzyCognitiveMap, changes::Dict{String,Float64}, iterations::Int=10)

Run a what-if scenario by temporarily modifying concept values and observing the outcome.

# Arguments
- `fcm`: The FCM to analyze
- `changes`: Dictionary mapping concept names to their new values
- `iterations`: Number of iterations to run
"""
function run_scenario(fcm::FuzzyCognitiveMap, changes::Dict{String,Float64}, iterations::Int=10)
    original_state = deepcopy(fcm.state)

    # Apply changes
    for (concept, value) in changes
        set_state!(fcm, concept, value)
    end

    run!(fcm, iterations)
    result = deepcopy(fcm.state)

    # # Restore original state
    # fcm.state .= original_state

    return result
end

"""
    compare_interventions(fcm::FuzzyCognitiveMap,
                         interventions::Vector{Dict{String,Float64}},
                         target_concepts::Vector{String},
                         iterations::Int=10)

Compare multiple interventions by their effects on target concepts.
"""
function compare_interventions(fcm::FuzzyCognitiveMap,
                             interventions::Vector{Dict{String,Float64}},
                             target_concepts::Vector{String},
                             iterations::Int=10)
    results = []

    for intervention in interventions
        new_fcm = deepcopy(fcm)
    outcome = run_scenario(new_fcm, intervention, iterations)

        # Extract target concept values
        target_values = Dict(
      concept => get_concept_value(new_fcm, concept)
            for concept in target_concepts
        )

        push!(results, (intervention=intervention, effects=target_values))
    end

    return results
end


"""
    analyze_concept_impact(fcm::FuzzyCognitiveMap,
                         concept::String,
                         values::Vector{Float64},
                         target_concepts::Vector{String})

Analyze how different values of a concept affect target concepts.
"""
function analyze_concept_impact(fcm::FuzzyCognitiveMap,
                              concept::String,
                              values::Vector{Float64},
                              target_concepts::Vector{String},
                              iterations::Int=10)
    results = []
    original_state = deepcopy(fcm.state)  # Store original state

    for value in values
        # Reset to original state before each test
        fcm.state .= original_state

        # Set test value and run simulation
        set_state!(fcm, concept, value)
        run!(fcm, iterations)

        impact = Dict(
            target => get_concept_value(fcm, target)
            for target in target_concepts
        )

        push!(results, (value=value, impact=impact))
    end

    # Restore original state
    fcm.state .= original_state
    return results
end

"""
    sensitivity_analysis(fcm::FuzzyCognitiveMap,
                        target_concept::String,
                        perturbation::Float64=0.1)

Perform sensitivity analysis on all concepts affecting the target concept.
"""
function sensitivity_analysis(fcm::FuzzyCognitiveMap,
  target_concept::String,
  perturbation::Float64=0.1,
  iterations::Int=10)
  original_state = deepcopy(fcm.state)
  baseline = get_concept_value(fcm, target_concept)
  sensitivities = Dict{String,NamedTuple{(:positive, :negative),Tuple{Float64,Float64}}}()

  for concept in fcm.concepts
    if concept != target_concept
      # Reset state before each test
      fcm.state .= original_state

      # Test positive perturbation
      set_state!(fcm, concept, get_concept_value(fcm, concept) + perturbation)
      run!(fcm, iterations)
      pos_effect = get_concept_value(fcm, target_concept) - baseline

      # Reset and test negative perturbation
      fcm.state .= original_state
      set_state!(fcm, concept, get_concept_value(fcm, concept) - perturbation)
      run!(fcm, iterations)
      neg_effect = get_concept_value(fcm, target_concept) - baseline

      # Store both effects separately
      sensitivities[concept] = (positive=pos_effect, negative=neg_effect)
    end
  end

  # Restore original state
  fcm.state .= original_state

  # Sort by maximum absolute effect
  return sort(collect(sensitivities),
    by=x -> max(abs(x.second.positive), abs(x.second.negative)),
    rev=true)
end


end # module
