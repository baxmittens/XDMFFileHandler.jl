function timestamp()
	str = string(Dates.unix2datetime(time()))
	str = replace(str,"-"=>"_")
	str = replace(str,":"=>"_")
	str = replace(str,"."=>"_")
end

function rename!(xdmf3f::XDMF3File,name::String)
	vtuf.name = name
	return nothing
end

#function Base.deepcopy(vtuf::VTUFile)
#	return XDMF3File(vtuf.name,vtuf.xmlfile,vtuf.xmlroot,vtuf.dataarrays,vtuf.appendeddata,vtuf.headertype,vtuf.offsets,similar(vtuf.data),vtuf.compressed_dat)
#end

function Base.similar(datf::XDMFDataField{T,N}) where {T,N}
	ret = deepcopy(datf)
	return ret
end

function Base.similar(dat::XDMFData)
	ret = deepcopy(dat)
	return ret
end

function Base.similar(xdmf3f::XDMF3File)
	ret = deepcopy(xdmf3f)
	return ret
end

function Base.fill!(datf::XDMFDataField{T,N}, c::Float64) where {T,N}
	fill!(datf.dat,c)
	return nothing
end

function Base.fill!(dat::XDMFData, c::Float64)
	for field in dat.fields
		fill!(field,c)
	end
	return nothing
end

function Base.fill!(xdmf3f::XDMF3File, c::Float64)
	fill!(xdmf3f.idata,c)
	return nothing
end

function Base.zero(datf::XDMFDataField{T,N}) where {T,N}
	ret = similar(datf)
	fill!(ret,zero(T))
	return ret
end

function Base.zero(dat::XDMFData)
	ret = similar(dat)
	fill!(ret,0.0) #todo add zero methods
	return ret
end

function Base.zero(xdmf3f::XDMF3File)
	ret = similar(xdmf3f)
	fill!(ret,0.0)
	return ret
end

function Base.one(datf::XDMFDataField{T,N}) where {T,N}
	ret = similar(datf)
	fill!(ret,1.0)
	return ret
end

function Base.one(dat::XDMFData)
	ret = similar(dat)
	fill!(ret,1.0)
	return ret
end

function Base.one(xdmf3f::XDMF3File)
	ret = similar(xdmf3f)
	fill!(ret,1.0)
	return ret
end

function Base.getindex(dat::XDMFData, str::String)
	ind = findfirst(x->x==str,dat.names)
	dat.fields[ind].dat
end

function Base.getindex(xdmf3f::XDMF3File, str::String)
	return xdmf3f.idata[str]
end