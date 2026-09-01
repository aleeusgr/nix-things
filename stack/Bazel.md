Bazel is an *[artifact-based](https://bazel.build/basics/artifact-based-builds)* build system.
(src, rules) -> self-contained binary
C++, Java, iOS, Android, Haskell rules repo.

[Build tool](https://en.wikipedia.org/wiki/Build_automation)
Source code -> build tool -> software artifact.
An abstraction layer on top of the compiler.
Multi-location, multi-language, 
Manage order of build
Automate dependency management: updates, version control.

buildfiles in Bazel are a **declarative** manifest describing a set of artifacts to build, their dependencies, and a limited set of options that affect how they’re built.

bazel :: name -> src -> deps -> target

advantages: parallelism, automate rebuild/reuse decision, reproducing builds, platform independence;

**rules** are used to extend target types; can build any language.

hashing dependencies: safety, security, reproducibility

Scalability


[starlark, bazel language](https://bazel.build/reference/glossary#starlark) is a subset of python

https://blog.bazel.build/2015/06/17/visualize-your-build.html - this requires managing dotfile

