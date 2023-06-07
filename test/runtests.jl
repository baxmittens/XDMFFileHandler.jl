using XDMFFileHandler

filename = "../test/test_THM_Ansicht_II_T1_grob_quadratic.xdmf"
xdmffile = XDMF3File(filename)

newfile = xdmffile*xdmffile
write(newfile, "test.xdmf")


using Combinatorics
top =  xdmffile.udata["topology"]
combs = collect(combinations(1:4,3))

faces = Vector{Vector{Int}}()

for i in 1:8:length(top)
	tet = top[i:i+3]
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
