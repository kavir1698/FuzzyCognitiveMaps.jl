function get_concept_value(fcm::FuzzyCognitiveMap, concept::String)
    return fcm.state[fcm.concept_indices[concept]]
end

function set_weight!(fcm::FuzzyCognitiveMap, from::String, to::String, value::Float64)
    abs(value) > 1 && error("Weight must be in range [-1, 1]")
    from_idx = fcm.concept_indices[from]
    to_idx = fcm.concept_indices[to]
    fcm.weights[from_idx, to_idx] = value
end

function set_state!(fcm::FuzzyCognitiveMap, concept::String, value::Float64)
    fcm.state[fcm.concept_indices[concept]] = value
end

function get_history(fcm::FuzzyCognitiveMap)
    return fcm.history
end

function get_convergence_history(fcm::FuzzyCognitiveMap)
    diffs = [norm(fcm.history[i+1] - fcm.history[i]) for i in 1:(length(fcm.history)-1)]
    return diffs
end
