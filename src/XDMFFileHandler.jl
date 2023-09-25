module XDMFFileHandler

using XMLParser
import XMLParser: XMLFile
using HDF5

import Dates
import LinearAlgebra: mul!, norm
import Base: +,-,*,/,^,<=
import AltInplaceOpsInterface: add!, minus!, pow!, max!, min!

uncompress_keywords = ["geometry","topology","MaterialIDs"]
interpolation_keywords = ["displacement","epsilon","pressure_interpolated","sigma","temperature_interpolated","temperature"]

struct XDMFDataField{T,N}
	dat::Array{T,N}
end

struct XDMFData
	names::Vector{String}
	fields::Vector{XDMFDataField}
	XDMFData() = new(Vector{String}(), Vector{XDMFDataField}())
end

mutable struct XDMF3File
	name::String
	path::String
	xmlfile::XMLFile
	xmlroot::XMLElement
	h5file::String
	h5path::String
	dataitems::Vector{XMLElement}
	idata::XDMFData
	udata::XDMFData
	overwrite::Bool
end

function getH5Pathes(xmlroot::XMLElement)
	attr = getElements(xmlroot,"Attribute")[1]
	name = getAttribute(attr,"Name")
	dit = getElements(attr,"DataItem")[1]
	fullpath = split(dit.content[1],name)[1]
	pathes = split(fullpath,":")
	h5file =  string(pathes[1])
	h5path =  string(pathes[2])
	return h5file,h5path
end

function extract_idata(h5file::String, h5path::String)
	fid = h5open(h5file, "r")
	names = Vector{String}()
	fields = Vector{XDMFDataField}()
	allkeys = keys(fid[h5path])
	idat = XDMFData()
	for keyword in interpolation_keywords
		if keyword ∈ allkeys
			tmp = read(fid,h5path*keyword)
			push!(idat.names,keyword)
			push!(idat.fields,XDMFDataField(deepcopy(tmp)))
		end
	end
	close(fid)
	return idat
end

function extract_udata(h5file::String, h5path::String)
	fid = h5open(h5file, "r")
	names = Vector{String}()
	fields = Vector{XDMFDataField}()
	allkeys = keys(fid[h5path])
	idat = XDMFData()
	for keyword in uncompress_keywords
		if keyword ∈ allkeys
			tmp = read(fid,h5path*keyword)
			push!(idat.names,keyword)
			push!(idat.fields,XDMFDataField(deepcopy(tmp)))
		end
	end
	close(fid)
	return idat
end

function XDMF3File(filename::String, overwrite=false)
	_splitpath = splitpath(filename)
	if length(_splitpath) > 1
		path = joinpath(_splitpath[1:end-1])	
		name = _splitpath[end]
	else
		path = "./"
		name = filename
	end
	xmlfile = read(XMLFile, filename)
	xmlroot = xmlfile.element
	dataitems = getElements(xmlroot,"DataItem")
	h5file,h5path = getH5Pathes(xmlroot)
	idata = extract_idata(joinpath(path,h5file), h5path)
	udata = extract_udata(joinpath(path,h5file), h5path)
	return XDMF3File(name, path, xmlfile, xmlroot, h5file, h5path, dataitems, idata, udata, overwrite)
end

include("./XDMFFileHandler/utils.jl")
include("./XDMFFileHandler/math.jl")
include("./XDMFFileHandler/io.jl")
include("./XDMFFileHandler/globaltolocal.jl")

export XDMF3File, getH5Path, XDMFData

end #module


#using XMLParser
#using XDMFFileHandler
#using HDF5
##using FileIO
#
#filename = "test_THM_Ansicht_II_T1_grob_quadratic.xdmf"
#xmlfile = read(XMLFile, filename)
#xmlroot = xmlfile.element
#dataitems = getElements(xmlroot,"DataItem")
#h5file = split(dataitems[1].content[1],".h5")[1]*".h5"
#times = read(fid,"times")
#h5path = getH5Path(xmlroot)
#
#fid = h5open(h5file, "r+")
#temps = read(fid,"meshes/Ansicht_II_T1_grob_quadratic/temperature_interpolated")
#
#
#timeels = getElements(xmlroot,"Time")
#
#for (t,el) in zip(times,timeels)
#	el.tag.attributes[1].val = string(t)
#end
#
#write("test_THM_Ansicht_II_T1_grob_quadratic_times.xdmf", xmlfile)