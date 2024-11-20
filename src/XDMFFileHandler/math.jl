function add!(zd1::XDMFDataField{T,N}, zd2::XDMFDataField{T,N}) where {T,N}
	zd1.dat .+= zd2.dat
	return nothing
end

function minus!(zd1::XDMFDataField{T,N}, zd2::XDMFDataField{T,N}) where {T,N}
	zd1.dat .-= zd2.dat
	return nothing
end

function add!(zd1::XDMFDataField{T,N}, a::Number) where {T,N}
	zd1.dat .+= a
	return nothing
end

function mul!(zd1::XDMFDataField{T,N}, c::Number) where {T,N}
	zd1.dat .*= c
	return nothing
end

function mul!(zd1::XDMFDataField{T,N}, zd2::XDMFDataField{T,N}, zd3::XDMFDataField{T,N}) where {T,N}
	@inbounds for i in 1:length(zd1.dat)
		zd1.dat[i] = zd2.dat[i] * zd3.dat[i]
	end
	return nothing
end

function mul!(zd1::XDMFDataField{T,N}, zd2::XDMFDataField{T,N}, fac::Float64) where {T,N}
	@inbounds for i in 1:length(zd1.dat)
		zd1.dat[i] = zd2.dat[i] * fac
	end
	return nothing
end

function pow!(zd1::XDMFDataField{T,N}, a::Number) where {T,N}
	@inbounds for i in 1:length(zd1.dat)
		zd1.dat[i] ^= a
	end
	return nothing
end

function div!(zd1::XDMFDataField{T,N}, a::Number) where {T,N}
	@inbounds for i in 1:length(zd1.dat)
		zd1.dat[i] /= a
	end
	return nothing
end

function max!(zd1::XDMFDataField{T,N}, zd2::XDMFDataField{T,N}) where {T,N}
	@inbounds for i in 1:length(zd1.dat)
		zd1.dat[i] = max(zd1.dat[i],zd2.dat[i])
	end
	return nothing
end

function min!(zd1::XDMFDataField{T,N}, zd2::XDMFDataField{T,N}) where {T,N}
	@inbounds for i in 1:length(zd1.dat)
		zd1.dat[i] = min(zd1.dat[i],zd2.dat[i])
	end
	return nothing
end

function norm(zd::XDMFDataField{T,N}) where {T,N}
	return norm(zd.dat)
end

function norm(zd::XDMFDataField{T,N},p::Real) where {T,N}
	return norm(zd.dat,p)
end

function add!(zd1::XDMFData, zd2::XDMFData)
	for (dat1,dat2) in zip(zd1.fields,zd2.fields)
		add!(dat1,dat2)
	end
	return nothing
end

function minus!(zd1::XDMFData, zd2::XDMFData)
	for (dat1,dat2) in zip(zd1.fields,zd2.fields)
		minus!(dat1,dat2)
	end
	return nothing
end

function add!(zd1::XDMFData, a::Number)
	for dat in zd1.fields	
		add!(dat,a)
	end
	return nothing
end

function mul!(zd1::XDMFData, c::Number)
	for dat in zd1.fields	
		mul!(dat,c)
	end
	return nothing
end


function mul!(zd1::XDMFData, zd2::XDMFData, zd3::XDMFData)
	for (dat1,dat2,dat3) in zip(zd1.fields,zd2.fields,zd3.fields)
		mul!(dat1,dat2,dat3)
	end
	return nothing
end

function mul!(zd1::XDMFData, zd2::XDMFData, fac::Float64)
	for (dat1,dat2) in zip(zd1.fields,zd2.fields)
		mul!(dat1,dat2,fac)
	end
	return nothing
end

function pow!(zd1::XDMFData, a::Number)
	for dat in zd1.fields	
		pow!(dat,a)
	end
	return nothing
end

function div!(zd1::XDMFData, a::Number)
	for dat in zd1.fields	
		div!(dat,a)
	end
	return nothing
end

function div!(zd1::XDMFData, zd2::XDMFData, zd3::XDMFData)
	for (dat1,dat2,dat3) in zip(zd1.fields,zd2.fields,zd3.fields)
		div!(dat1,dat2,dat3)
	end
	return nothing
end

function max!(zd1::XDMFData, zd2::XDMFData)
	for (dat1,dat2) in zip(zd1.fields,zd2.fields)
		max!(dat1,dat2)
	end
	return nothing
end

function min!(zd1::XDMFData, zd2::XDMFData)
	for (dat1,dat2) in zip(zd1.fields,zd2.fields)
		min!(dat1,dat2)
	end
	return nothing
end


import Base: +,-,*,/,^

function +(tpf1::XDMFData, tpf2::XDMFData)
	ret = similar(tpf1)
	fill!(ret,0.0)
	add!(ret,tpf1)
	add!(ret,tpf2)
	return ret
end

function -(tpf1::XDMFData, tpf2::XDMFData)
	ret = similar(tpf1)
	fill!(ret,0.0)
	add!(ret,tpf1)
	minus!(ret,tpf2)
	return ret
end

function *(tpf1::XDMFData, tpf2::XDMFData)
	ret = similar(tpf1)
	fill!(ret,0.0)
	mul!(ret,tpf1,tpf2)
	return ret
end

function /(tpf1::XDMFData, tpf2::XDMFData)
	ret = similar(tpf1)
	fill!(ret,0.0)
	div!(ret,tpf1,tpf2)
	return ret
end

function +(tpf::XDMFData, a::Number)
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	add!(ret,a)
	return ret
end
+(a::Number,tpf::XDMFData) = tpf+a

function -(tpf::XDMFData, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	add!(ret,-a)
	return ret
end

function -(a::T,tpf::XDMFData) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,a)
	minus!(ret,tpf)
	return ret
end

function *(tpf::XDMFData, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	mul!(ret,a)
	return ret
end
*(a::T,tpf::XDMFData) where T<:Number = tpf*a

function /(tpf::XDMFData, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	div!(ret,a)
	return ret
end

function ^(tpf::XDMFData, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	pow!(ret,a)
	return ret
end

function norm(dat::XDMFData,p::Real)
	interp_data = dat.fields
	return norm(map(x->norm(x,p),interp_data),p)
end

function <=(zd1::XDMFData, zd2::XDMFData)
	ret = true
	for (dat1,dat2) in zip(zd1.fields,zd2.fields)
		ret *= all(abs.(dat1.dat) .<= abs.(dat2.dat))
	end
	return ret
end

function add!(zd1::XDMF3File, zd2::XDMF3File)
	add!(zd1.idata,zd2.idata)
	return nothing
end

function minus!(zd1::XDMF3File, zd2::XDMF3File)
	minus!(zd1.idata,zd2.idata)
	return nothing
end

function add!(zd1::XDMF3File, a::Number)
	add!(zd1.idata, a)
	return nothing
end

function mul!(zd1::XDMF3File, c::Number)
	mul!(zd1.idata, c)
	return nothing
end

function mul!(zd1::XDMF3File, zd2::XDMF3File, zd3::XDMF3File)
	mul!(zd1.idata, zd2.idata, zd3.idata)
	return nothing
end

function mul!(zd1::XDMF3File, zd2::XDMF3File)
	mul!(zd1.idata, zd1.idata, zd2.idata)
	return nothing
end

function mul!(zd1::XDMF3File, zd2::XDMF3File, fac::Float64)
	mul!(zd1.idata, zd2.idata, fac)
	return nothing
end

function pow!(zd1::XDMF3File, a::Number)
	pow!(zd1.idata, a)
	return nothing
end

function div!(zd1::XDMF3File, a::Number)
	div!(zd1.idata, a)
	return nothing
end

function div!(zd1::XDMF3File, zd2::XDMF3File, zd3::XDMF3File)
	div!(zd1.idata, zd2.idata, zd3.idata)
	return nothing
end

function max!(zd1::XDMF3File, zd2::XDMF3File)
	max!(zd1.idata, zd2.idata)
	return nothing
end

function min!(zd1::XDMF3File, zd2::XDMF3File)
	min!(zd1.idata, zd2.idata)
	return nothing
end

function +(tpf1::XDMF3File, tpf2::XDMF3File)
	ret = similar(tpf1)
	fill!(ret,0.0)
	add!(ret,tpf1)
	add!(ret,tpf2)
	return ret
end

function +(tpf1::XDMF3File)
	ret = similar(tpf1)
	fill!(ret,0.0)
	add!(ret,tpf1)
	return ret
end

function -(tpf1::XDMF3File, tpf2::XDMF3File)
	ret = similar(tpf1)
	fill!(ret,0.0)
	add!(ret,tpf1)
	minus!(ret,tpf2)
	return ret
end

function -(tpf1::XDMF3File)
	ret = similar(tpf1)
	fill!(ret,0.0)
	minus!(ret,tpf1)
	return ret
end

function *(tpf1::XDMF3File, tpf2::XDMF3File)
	ret = similar(tpf1)
	fill!(ret,0.0)
	mul!(ret,tpf1,tpf2)
	return ret
end

function +(tpf::XDMF3File, a::Number)
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	add!(ret,a)
	return ret
end
+(a::Number,tpf::XDMF3File) = tpf+a

function -(tpf::XDMF3File, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	add!(ret,-a)
	return ret
end

function -(a::T,tpf::XDMF3File) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,a)
	minus!(ret,tpf)
	return ret
end

function *(tpf::XDMF3File, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	mul!(ret,a)
	return ret
end
*(a::T,tpf::XDMF3File) where T<:Number = tpf*a

function /(tpf::XDMF3File, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	div!(ret,a)
	return ret
end

function /(tpf1::XDMF3File, tpf2::XDMF3File)
	ret = similar(tpf1)
	fill!(ret,0.0)
	div!(ret,tpf1,tpf2)
	return ret
end

function ^(tpf::XDMF3File, a::T) where T<:Number
	ret = similar(tpf)
	fill!(ret,0.0)
	add!(ret,tpf)
	pow!(ret,a)
	return ret
end

function norm(tpf::XDMF3File,p::Real)
	return norm(tpf.idata,p)
end

function <=(tpf1::XDMF3File, tpf2::XDMF3File)
	return tpf1.idata <= tpf2.idata
end