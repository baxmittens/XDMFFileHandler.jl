# XDMFFileHandler.jl

A Julia library that implements basic algebraic operations for XDMF data.

## Introduction

With increasing computing resources, investigating uncertainties in simulation results is becoming an increasingly important factor. A discrete numerical simulation is computed several times with different deviations of the input parameters to produce different outputs of the same model to analyze those effects. The relevant stochastic or parametric output variables, such as mean, expected value, and variance, are often calculated and visualized only at selected individual points of the whole domain. This project aims to provide a simple way to perform stochastic/parametric post-processing of numerical simulations on entire domains using the XDMF file system and the Julia language as an example.

## Install

```julia
import Pkg
Pkg.add("XDMFFileHandler")
```

