function Base.write(vtufile::VTUFile)
	update_xml!(vtufile)
	name = vtufile.name
	if add_timestamp
		splitstr = split(name,".vtu")
		@assert length(splitstr) == 2 && isempty(splitstr[end])
		name = splitstr[1] * "_" * timestamp() * ".vtu"
	end
	#f = open(name,"w")
	#writeXMLElement(f,vtufile.xmlroot)
	#close(f)
	write(name, vtufile.xmlfile)
end