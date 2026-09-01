https://unix.stackexchange.com/questions/272660/how-to-split-etc-nixos-configuration-nix-into-separate-modules
https://discourse.nixos.org/t/flake-and-home-manager-20-11-configuration/20211

As a Nix module (file with extension `.nix`) can contain any Nix expression, you would expect the NixOS configuration file (`/etc/nixos/configuration.nix`) to contain a single Nix expression as its file contents.

https://nixos.org/manual/nix/stable/language/values.html
`function` - `let negate = x: !x;`
`set`
`attribute set` is a collection of name-value-pairs

`nixos-generate-config` -> hardware-configuration.nix

release notes

having two different flakes for a single machine is not ideal.



### Nobbz
How to understand another person's logic? 
Understanding code written by other developer is no easy task!
1. Find **entry point**
`git checkout 1408afe48dac7e559bc3118f53ff1cdf075b8163`README
> There are some old repositories I used to configure stuff. My actual dotfiles have been private for a long time as they contain secrets.

What is the command that the person used to test their code?
How to use git?
branches, commits, features, tree.

Every programmer works like that: write some code -> run it.
In python you do Ctrl + Enter in Jupyter, but it takes forever to do any decent computation. 
In Haskell, the 'default' method is `cabal run`
You don't usually do much in `repl`, what is a good use for `repl`?

lets imagine a function `run-my-code.sh`, "using shell" 
Isn't it facinating? the whole copmuter is a function;  

bash script is a *universal* test. Example: request to cli; 
Excercise: write tests; unit tests, integration tests, api tests; 

lets model a request to cardano-cli as a function. 
What it has as elements of its domain type? co-domain type?
is the compiler to run (who said you should compile your .hs with ghc? try with gcc, and see the error it produces)
When you request cardano-cli, what you do is you imagine (in code) the type  `test` 

How to find where the error is? 