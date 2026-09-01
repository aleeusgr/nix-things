**set** ~ python dict  
In nix it happens that sets are given as arguments to functions.  
  
... - Accepting unexpected attributes in argument set:  
add_a_b = { a, b, ... }: a + b
add_a_b 1 3 5 will not give an error.

`realpath $(which nix)`

`binary cache` builds Nix packages and **caches** the result for other machines. Any machine with Nix installed can be a binary cache for another one, no matter the operating system.

**cache** hardware or software *component* that stores data so that future requests for that data can be served faster;

nix: declarative, reproducible, reliable systems.

declarative: user describes the desired configuration, and the process of building it is automated.
reproducible: determenistic, always the same, no matter the hardware or point in time and space where its built
Reliable: installing a package never breaks another, rollbacks are easy.




