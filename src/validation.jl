function validate_fcm_inputs(concepts, weights, initial_state)
    n = length(concepts)

    # Dimension checks
    size(weights) != (n, n) && error("Weights matrix must be $n x $n")
    length(initial_state) != n && error("Initial state must have length $n")

    # Value checks
    any(isnan.(weights)) && error("Weight matrix contains NaN values")

    # Isolated nodes check
    row_zeros = all(iszero, weights, dims=2)
    col_zeros = all(iszero, weights, dims=1)
    isolated_indices = findall(row_zeros .& col_zeros')
    if !isempty(isolated_indices)
        isolated_concepts = concepts[isolated_indices]
        @warn "Found completely isolated concepts: $isolated_concepts"
    end

    # Range checks
    !all(-1 .<= weights .<= 1) && error("Weight values must be in range [-1, 1]")
    !all(diag(weights) .== 0) && error("Diagonal elements must be zero in FCM weight matrix")
end
