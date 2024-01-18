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

function add_nodal_scalar_field!(xdmf3f::XDMF3File, name::String, data)
	maingrid = getElements(xdmf3f.xmlroot,"Grid")
	@assert length(maingrid) == 1
	grid = first(getElements(first(maingrid),"Grid"))
	allgridattr = getElements(grid,"Attribute")
	filteredattributes = filter(x->hasAttributekey(x, "Name") && getAttribute(x, "Name")==name, allgridattr)
	@assert isempty(filteredattributes) "field with name $name already exists!"
	el_geometry = first(getElements(grid,"Geometry"))
	new_attr = deepcopy(el_geometry)
	new_attr.tag.name = "Attribute"
	dataitem = new_attr.content[1]
	dims_str = getAttribute(dataitem, "Dimensions")
	firstdim_str = split(dims_str)[1]
	firstdim_int = parse(Int,firstdim_str)
	@assert length(data) == firstdim_int
	dataitem.content[1] = replace(split(dataitem.content[1],"|")[1],"geometry"=>name)
	setAttribute(dataitem,"Dimensions",firstdim_str)
	new_attr.tag.attributes = XMLAttribute[
		XMLAttribute("Center","Node"),
		XMLAttribute("ElementCell",""),
		XMLAttribute("ElementDegree","0"),
		XMLAttribute("ElementFamily",""),
		XMLAttribute("ItemType",""),
		XMLAttribute("Name",name),
		XMLAttribute("Type","None")
	]
	#fid = h5open(xdmf3f.h5file,"r+")
	#obj = joinpath(xdmf3f.h5path,name)
	#write(fid, obj, data)
	#close(fid)
	push!(grid.content, new_attr)
	xdmf3f.dataitems = getElements(xmlroot,"DataItem")
	@assert !(name ∈ xdmf3f.idata.names) "Name $name already exists in interpolation data"
	push!(xdmf3f.idata.names,name)
	push!(xdmf3f.idata.fields,XDMFDataField(data))
	return nothing
end

function delete_field(xdmf3f::XDMF3File, fieldname::String)
	return nothing
end


#templatefieldname = "temperature_interpolated"
#newfieldname = "sobol_index"
#filename="varval_in_temp.xdmf"
#xmlfile = read(XMLFile, filename)
#xmlroot = xmlfile.element
#maingrid = getElements(xmlroot,"Grid")
#@assert length(maingrid) == 1
#grids = getElements(first(maingrid),"Grid")
##for grid in grids
#	grid = first(grids)
#	attributes = getElements(grid,"Attribute")
#	filteredattributes = filter(x->hasAttributekey(x, "Name") && getAttribute(x, "Name")==templatefieldname, attributes)
#	@assert length(filteredattributes) == 1
#	attribute = first(filteredattributes)
#	newattr = deepcopy(attribute)
#	setAttribute(newattr,"Name",newfieldname)
#	newattr.content[1].content[1] = replace(newattr.content[1].content[1], templatefieldname=>newfieldname)
#	splitnewattr = split(newattr.content[1].content[1],"|")
#	splitnewattr[2]
##end
#
#
#
#xdmf3f = XDMF3File(filename)
##fid = h5open(xdmf3f.h5file,"r+")
#dat = rand(1493,1)
#name = "randomfield"
#add_nodal_scalar_field!(xdmf3f, name, dat)
#write(xdmf3f, "test.xdmf")
#
#fid = h5open(xdmf3f.h5file,"r+")
#obj = joinpath(xdmf3f.h5path,name)
#delete_object(fid, obj)
#close(fid)