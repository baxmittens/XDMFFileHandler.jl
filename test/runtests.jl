using XDMFFileHandler

filename = "../test/test_THM_Ansicht_II_T1_grob_quadratic.xdmf"
xdmffile = XDMF3File(filename)

new = xdmffile*xdmffile
write(xdmffile, "test.xdmf")