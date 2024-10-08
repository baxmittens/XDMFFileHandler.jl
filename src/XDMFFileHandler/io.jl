function create_and_update_hdf5!(xdmf3f::XDMF3File, newh5::String, newpath::String, force=false)
	path,oldh5 = xdmf3f.path,xdmf3f.h5file
	_oldh5 = joinpath(path,oldh5)
	_newh5 = joinpath(newpath,newh5)
	xdmf3f.path = newpath
	cp(_oldh5,_newh5, force=force)
	fid = h5open(_newh5,"r+")
	fidkeys = keys(fid[xdmf3f.h5path])
	for (name,field) in zip(xdmf3f.idata.names,xdmf3f.idata.fields)
		obj = joinpath(xdmf3f.h5path,name)
		if name ∈ fidkeys
			delete_object(fid, obj)
		end
		write(fid, obj, field.dat)
	end
	for dataitem in xdmf3f.dataitems
		con = dataitem.content[1]
		dataitem.content[1] = replace(con, xdmf3f.h5file=>newh5)
	end
	xdmf3f.h5file = newh5
	close(fid)
	return nothing
end

#function correct_time_steps!(xdmf::XDMF3File)
#	h5file,xmlroot,path = xdmf.h5file,xdmf.xmlroot,xdmf.path
#	_h5file = joinpath(path,h5file)
#	fid = h5open(_h5file, "r")
#	times = read(fid, "times")
#	timeels = getElements(xmlroot, "Time")
#	for (t,el) in zip(times,timeels)
#		el.tag.attributes[1].val = string(t)
#	end
#	close(fid)
#	return nothing
#end

function update_xml!(xdmf3f::XDMF3File,newh5::String)
	#correct_time_steps!(xdmf3f)
	for dataitem in xdmf3f.dataitems
		con = dataitem.content[1]
		dataitem.content[1] = replace(con, xdmf3f.h5file=>newh5)
	end
	return nothing
end

function Base.write(xdmf3f::XDMF3File, name::String, write_timest::Bool=true, path::String="./")
	@assert length(splitpath(name))==1 && split(name,".")[end] == "xdmf" "Name must end with .xdmf and is not allowed to contain `/`. Path can be specified by optional argument `write(xdmf3f::XDMF3File, name::String, write_timest::Bool, path::String)`"
	if write_timest
		timest = timestamp()
		newh5 = split(xdmf3f.h5file,".")[1]*timest*".h5"
	else
		newh5 = split(xdmf3f.h5file,".")[1]*".h5"
	end
	create_and_update_hdf5!(xdmf3f, newh5, path)
	#update_xml!(xdmf3f,newh5)
	return write(joinpath(xdmf3f.path,name), xdmf3f.xmlfile)
end

function Base.write(xdmf3f::XDMF3File, name::String, newh5::String, path="./")
	@assert length(splitpath(name))==1 && split(name,".")[end] == "xdmf" "$name must end with .xdmf and is not allowed to contain `/`. Path can be specified by optional argument `write(xdmf3f::XDMF3File, name::String, write_timest::Bool, path::String)`"
	@assert split(newh5,".")[end] == "h5" "$newh5 must end wit .h5"
	create_and_update_hdf5!(xdmf3f, newh5, path, true)
	return write(joinpath(xdmf3f.path,name), xdmf3f.xmlfile)
end