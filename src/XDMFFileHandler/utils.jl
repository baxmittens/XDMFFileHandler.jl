function timestamp()
	str = string(Dates.unix2datetime(time()))
	str = replace(str,"-"=>"_")
	str = replace(str,":"=>"_")
	str = replace(str,"."=>"_")
end

function rename!(vtuf::VTUFile,name::String)
	vtuf.name = name
	return nothing
end

#function Base.deepcopy(vtuf::VTUFile)
#	return XDMF3File(vtuf.name,vtuf.xmlfile,vtuf.xmlroot,vtuf.dataarrays,vtuf.appendeddata,vtuf.headertype,vtuf.offsets,similar(vtuf.data),vtuf.compressed_dat)
#end

function Base.similar(xdmf3f::XDMF3File)
	ret = deepcopy(xdmf3f)
	return ret
end

function Base.fill!(xdmf3f::XDMF3File, c::Float64)
	fill!(ret.data,c)
	return nothing
end

function Base.zero(xdmf3f::XDMF3File)
	ret = similar(vtu)
	fill!(ret,0.0)
	return ret
end

function Base.one(xdmf3f::XDMF3File)
	ret = similar(vtu)
	fill!(ret,1.0)
	return ret
end



function Base.getindex(xdmf3f::XDMF3File, str::String)
	ind = findfirst(x->replace(x,"\""=>"")==str,vtu.data.names)
	if ind ∈ vtu.data.idat
		ind = findfirst(x->x==ind,vtu.data.idat)
		return vtu.data.interp_data[ind].dat
	else
		return vtu.data.data[ind].dat
	end
end