"""
    sigmoid(x)

Sigmoid activation function that maps any real number to the interval (0,1).
"""
sigmoid(x) = 1 / (1 + exp(-x))

"""
    tanh_activation(x)

Hyperbolic tangent activation function that maps any real number to the interval (-1,1).
"""
tanh_activation(x) = tanh(x)

"""
    linear(x)

Linear activation function that returns the input value unchanged.
"""
linear(x) = x

"""
    triangular(x; a=-1, b=0, c=1)

Triangular activation function that creates a triangular membership function.
"""
function triangular(x; a=-1, b=0, c=1)
    max(0, min((x - a) / (b - a), (c - x) / (c - b), 1))
end
