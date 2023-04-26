function create_and_updata_hdf5!(xdmf3f::XDMF3File, newh5::String)
	path,oldh5 = xdmf3f.path,xdmf3f.h5file
	_oldh5 = joinpath(path,oldh5)
	_newh5 = joinpath(path,newh5)
	cp(_oldh5,_newh5)
	fid = h5open(_newh5,"r+")
	for (name,field) in zip(xdmf3f.idata.names,xdmf3f.idata.fields)
		write(fid, joinpath(xdmf3f.h5path,name), field.dat)
	end
	close(fid)
	return nothing
end

function correct_time_steps!(xdmf::XDMF3File)
	h5file,xmlroot = xdmf.h5file,xdmf.xmlroot
	fid = h5open(h5file, "r")
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

function Base.write(xdmf3f::XDMF3File, name::String)
	@assert length(splitpath(name))==1 && split(name,".")[end] == "xdmf"
	timest = timestamp()
	newh5 = split(xdmffile.h5file,".")[1]*timest*".h5"
	update_or_create_hdf5!(xdmf3f)
	update_xml!(xdmf3f,newh5)
	return write(joinpath(xdmf3f.path,name), vtufile.xmlfile)
end