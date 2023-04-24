module XDMFFileHandler

using XMLParser

interpolation_keywords = ["displacement","epsilon","pressure_interpolated","sigma","temperature_interpolated"]

struct XDMF3File
	name::String
	xmlroot::XMLElement
end

end #module