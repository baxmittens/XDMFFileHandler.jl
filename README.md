# XDMFFileHandler.jl

A Julia library that implements basic algebraic operations for XDMF data.

## Introduction

With increasing computing resources, investigating uncertainties in simulation results is becoming an increasingly important factor. A discrete numerical simulation is computed several times with different deviations of the input parameters to produce different outputs of the same model to analyze those effects. The relevant stochastic or parametric output variables, such as mean, expected value, and variance, are often calculated and visualized only at selected individual points of the whole domain. This project aims to provide a simple way to perform stochastic/parametric post-processing of numerical simulations on entire domains using the XDMF file system and the Julia language as an example.

## Install

```julia
import Pkg
Pkg.add("XDMFFileHandler")
```

## Usage

The idea of this project is not to create xdmf files from scratch. Instead, it is assumed that xdmf files are available as a result of an external simulation program and that this data is to be loaded, modified (think of custom post-processing which your simulation software isn't capable of) and written to hard drive.

### Add unpack / interpolation keywords

Not all xdmf data is loaded by default. There is data that is only uncompressed but not affected from arithmetic operations. This data is stored in `XDMFFileHandler.uncompress_keywords`. Field names stored in `XDMFFileHandler.interpolation_keywords` are uncompress and affected by arithmetic operations

```julia
using XDMFFileHandler
# set keywords
XDMFFileHandler.uncompress_keywords = ["geometry","topology","MaterialIDs"]
XDMFFileHandler.interpolation_keywords = ["displacement","epsilon","pressure_interpolated","sigma","temperature_interpolated","temperature"]
# add keywords
push!(XDMFFileHandler.uncompress_keywords, "field1")
push!(XDMFFileHandler.interpolation_keywords, "field2")
```

### Load an xdmf file

```julia
xdmf = XDMF3File("path/to/xdmffile.xdmf")
```

### Arithmetic operations

You can perform arbitrary mathematical operations on xdmf data with operators `+,-,*,^`. All operators act `scalar-wise` on each number of each field of the xdmf file, like it would usually be done by broadcasting. Broadcasting was not implemented for `XDMF3File` since it is a nested data type for which Julia does not support broadcasting. Allocation-free arithmetic operators are therefore implemented by the [AltInplaceOpsInterface](https://github.com/baxmittens/AltInplaceOpsInterface.jl).

```julia
xdmf *= xdmf
xdmf ^= 0.5
xdmf += 1.0
```

### Write to file

For file writing, a xdmf file path and a h5 file path has to be specified. Be careful not to overwrite your original data!

```julia
write(xdmf, "extended_postproc.xdmf", "extended_postproc.h5")
```