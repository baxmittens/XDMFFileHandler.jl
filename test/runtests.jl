using XDMFFileHandler

#filename = "../test/test_THM_Ansicht_II_T1_grob_quadratic.xdmf"

filename = "./julia/dev/XDMFFileHandler/test/test_THM_grobnetz_quadr.xdmf"

xdmffile = XDMF3File(filename)

newfile = xdmffile*xdmffile
write(newfile, "test.xdmf")


using Combinatorics
top =  xdmffile.udata["topology"]
combs = collect(combinations(1:4,3))

faces = Vector{Vector{Int}}()

for i in 1:11:length(top)
	tet = top[i+1:i+4]
	for comb in combs
		push!(faces,tet[comb])
	end
end

hullfaces = Vector{Vector{Int}}()
sortedfaces = map(sort,faces)
for (i,face) in enumerate(sortedfaces)
	if length(findall(x->x==face,sortedfaces)) == 1
		push!(hullfaces, faces[i])
	end
end
