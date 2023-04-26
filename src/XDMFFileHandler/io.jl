function create_and_updata_hdf5!(xdmf3f)
	
end

function Base.write(xdmf3f::XDMF3File, name::String)
	update_or_create_hdf5!(xdmf3f)
	update_xml!(xdmf3f)
	write(xdmf3f.name, vtufile.xmlfile)
end