module HebbianLearning

using LinearAlgebra
using Statistics

export train_hebbian!, train_oja!, train_generalized_hebbian!

"""
    train_hebbian!(fcm, learning_rate::AbstractFloat=0.01, iterations::Int=1)

Apply basic Hebbian learning rule to update FCM weights
W(t+1) = W(t) + η * x(t) * x(t)ᵀ

# Parameters:
- fcm: FuzzyCognitiveMap instance
- learning_rate: Learning rate parameter η
- iterations: Number of training iterations

# Mechanistic Definition

Learning is defined as adaptive changes in a system's parameters due to experience. Here:

- Experience: The FCM's state vector x represents system activity.
- Adaptation: Weights evolve to encode statistical relationships between concepts (x_i and x_j). Positive covariance (co-activation of x_i and x_j) strengthens W_ij. Anti-correlation weakens W_ij (if allowed by clamping). Over time, weights encode the system's "memory" of concept relationships.
"""
function train_hebbian!(fcm, learning_rate::AbstractFloat=0.01, iterations::Int=1)
    for _ in 1:iterations
        x = fcm.state

        # Hebb's postulate: "What fires together, wires together."
        # The outer product x * x' computes pairwise correlations between all concepts in the FCM's state vector x.
        Δw = learning_rate * (x * x')

        # Update weights while preserving constraints
        new_weights = fcm.weights + Δw

        # Ensure diagonal remains zero and weights stay in [-1,1]
        for i in 1:length(fcm.concepts)
            new_weights[i,i] = 0
            for j in 1:length(fcm.concepts)
                new_weights[i,j] = clamp(new_weights[i,j], -1, 1)
            end
        end

        fcm.weights = Float16.(new_weights)
    end
end

"""
    train_oja!(fcm, learning_rate::Float64=0.01, iterations::Int=1)


Apply Oja's learning rule to update FCM weights
W(t+1) = W(t) + η * x(t) * (x(t)ᵀ - W(t)x(t)ᵀ)

This rule helps prevent unbounded weight growth.
"""
function train_oja!(fcm, learning_rate::Float64=0.01, iterations::Int=1)
    for _ in 1:iterations
        x = fcm.state
        y = fcm.weights * x

        # Oja's update rule
        Δw = learning_rate * (x * x' - y * x')

        new_weights = fcm.weights + Float16.(Δw)

        # Apply constraints
        for i in 1:length(fcm.concepts)
            new_weights[i,i] = 0
            for j in 1:length(fcm.concepts)
                new_weights[i,j] = clamp(new_weights[i,j], -1, 1)
            end
        end

        fcm.weights = new_weights
    end
end

"""
Apply generalized Hebbian learning rule to update FCM weights.

This function combines two biologically inspired terms:

1. Hebbian term (x * x'): Strengthens weights based on correlated activity (classic "fire together, wire together").
2. Anti-Hebbian/decay term (-decay * fcm.weights): Implements synaptic depression, preventing runaway excitation and enforcing forgetting (similar to weight decay in machine learning, e.g L2 regularization).

As a result
- The Hebbian term captures correlations between concepts.
- The decay term prevents overfitting by penalizing large weights, leading to sparser, more interpretable networks.
- The system converges to a trade-off between memorization (Hebbian) and regularization (decay).

| Feature | Basic Hebbian | Oja’s Rule | Your Generalized Rule |
| --- | --- | --- | --- |
| Stability | Unbounded | Self-normalizing | Tunable via decay |
| Interpretability | Correlations only | PCA-like | Sparse, regularized |
| Biological Basis | Pure LTP | LTP + LTD | LTP + Homeostasis |
| Computational Cost | Low | Moderate | Low |
"""
function train_generalized_hebbian!(fcm, learning_rate::Float64=0.01,
                                  decay::Float64=0.1, iterations::Int=1)
    for _ in 1:iterations
        x = fcm.state

        # Compute correlation and anti-Hebbian terms
        correlation = x * x'
        anti_hebbian = decay * fcm.weights

        # Combined update
        Δw = learning_rate * (correlation - anti_hebbian)

        new_weights = fcm.weights + Float16.(Δw)

        # Apply constraints
        for i in 1:length(fcm.concepts)
            new_weights[i,i] = 0
            for j in 1:length(fcm.concepts)
                new_weights[i,j] = clamp(new_weights[i,j], -1, 1)
            end
        end

        fcm.weights = new_weights
    end
end

end # module
