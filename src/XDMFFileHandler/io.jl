function create_and_update_hdf5!(xdmf3f::XDMF3File, newh5::String, newpath::String)
	path,oldh5 = xdmf3f.path,xdmf3f.h5file
	_oldh5 = joinpath(path,oldh5)
	_newh5 = joinpath(newpath,newh5)
	xdmf3f.path = newpath
	cp(_oldh5,_newh5)
	fid = h5open(_newh5,"r+")
	for (name,field) in zip(xdmf3f.idata.names,xdmf3f.idata.fields)
		obj = joinpath(xdmf3f.h5path,name)
		delete_object(fid, obj)
		write(fid, obj, field.dat)
	end
	close(fid)
	return nothing
end

function correct_time_steps!(xdmf::XDMF3File)
	h5file,xmlroot,path = xdmf.h5file,xdmf.xmlroot,xdmf.path
	_h5file = joinpath(path,h5file)
	fid = h5open(_h5file, "r")
	times = read(fid, "times")
	timeels = getElements(xmlroot, "Time")
	for (t,el) in zip(times,timeels)
		el.tag.attributes[1].val = string(t)
	end
	close(fid)
	return nothing
end

function update_xml!(xdmf3f::XDMF3File,newh5::String)
	correct_time_steps!(xdmf3f)
	for dataitem in xdmf3f.dataitems
		con = dataitem.content[1]
		dataitem.content[1] = replace(con, xdmf3f.h5file=>newh5)
	end
	xdmf3f.h5file = newh5
	return nothing
end

function Base.write(xdmf3f::XDMF3File, name::String, path="./")
	@assert length(splitpath(name))==1 && split(name,".")[end] == "xdmf"
	timest = timestamp()
	newh5 = split(xdmf3f.h5file,".")[1]*timest*".h5"
	create_and_update_hdf5!(xdmf3f, newh5, path)
	update_xml!(xdmf3f,newh5)
	return write(joinpath(xdmf3f.path,name), xdmf3f.xmlfile)
end