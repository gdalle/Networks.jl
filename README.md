# Networks.jl

[![CI](https://github.com/bsc-quantic/Networks.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/bsc-quantic/Networks.jl/actions/workflows/CI.yml)
[![Documentation: stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://bsc-quantic.github.io/Networks.jl/)
[![Documentation: dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://bsc-quantic.github.io/Networks.jl/dev/)

Networks.jl is an work-in-progress proposal for an alternative graph interface in Julia.
It is a product of my frustations developing custom graph-like types on top of Graphs.jl.
While performant, Graphs.jl has several limitations:

- No support for hyper-edges, open-edges or multi-edges.
- No easy way for delegation on custom graph types (user needs to reimplement the API).
- Vertices must always be of `Integer` type.
- Basic `SimpleGraph` implementation doesn't keep vertex ids when deleting a vertex.

While experimenting with Tenet.jl, I came to the conclusion that the problem is in the fundamental design and that a package on top of the `AbstractGraph` interface won't remedy it.
Networks.jl tries to fix these design issues

1. Like networkx, almost any object should be able to be used as a vertex.
2. Use new interfaces for new functionalities.
3. Automatic delegation of interface implementations.
4. No reliance on trait or interface packages.
