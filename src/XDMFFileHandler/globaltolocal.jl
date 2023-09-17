using StaticArrays
import Printf.@printf


function smallNorm(vec::Array{Float64,1})
        if size(vec,1) == 2
                @inbounds return sqrt(vec[1]*vec[1]+vec[2]*vec[2])
        elseif size(vec,1) == 3
                @inbounds return sqrt(vec[1]*vec[1]+vec[2]*vec[2]+vec[3]*vec[3])
        else
                error("smallNorm: vector must be either 2D or 3D")
        end
end

function Tri3_shapeFun(ec::AbstractArray)
        N =  SMatrix{3,1,Float64,3}(1.0-ec[1]-ec[2], ec[1], ec[2])
        return N
end

function Tri3_shapeFunDeriv(ec::AbstractArray)
        dN = SMatrix{3,2,Float64,6}(-1., 1., 0.,-1.,0.,1.)
        return dN
end

function Tri6_shapeFun(ec::AbstractArray)
        N =  SMatrix{6,1,Float64,6}(
            (1.0-ec[1]-ec[2])*(1-2*ec[1]-2*ec[2]), 
            ec[1]*(2*ec[1]-1), 
            ec[2]*(2*ec[2]-1),
            4*ec[1]*(1.0-ec[1]-ec[2]),
            4*ec[1]*ec[2],
            4*ec[2]*(1.0-ec[1]-ec[2])
            )
        return N
end

function Tri6_shapeFunDeriv(ec::AbstractArray)
        dN = SMatrix{3,2,Float64,6}(
            4*ec[1]+4*ec[2]-3., 4*ec[1]+4*ec[2]-3, 
            4*ec[1]-1, 0.,
            0.,  4*ec[2]-1,
            -4*(2*ec[1]+ec[2]-1), -4*ec[1],
            4*ec[2], 4*[1],
            -4*ec[2], -4(ec[1]+2*ec[2]-1)
            )
        return dN
end

function globalToLocalGuess(xPt, nodalX)
        A = vcat(ones(1,3),nodalX)
        x = vcat(ones(SVector{1,Float64}), xPt)
        λ = A\x        
        return vec(λ[2:end])
end

function Tri3_checkInHullConstraint(ec::Array{Float64,1})
        s = ec[1]+ec[2] - 1.0 > 1e-10
        sm = ec[1] < -1e-10 || ec[2] < -1e-10
        if sm || s
                return false
        else
                return true
        end
end

function _sign(p1::AbstractArray, p2::AbstractArray, p3::AbstractArray)
    return (p1[1] - p3[1]) * (p2[2] - p3[2]) - (p2[1] - p3[1]) * (p1[2] - p3[2]);
end

function PointInTri3(pt::AbstractArray, v1::AbstractArray, v2::AbstractArray, v3::AbstractArray)
    d1 = _sign(pt, v1, v2)
    d2 = _sign(pt, v2, v3)
    d3 = _sign(pt, v3, v1)

    has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0)
    has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0)

    return !(has_neg && has_pos)
end

function globalToLocal(xPt::Array{Float64,1}, nodalX::Array{Float64,2}, shapeFun::T1, shapeFunDeriv::T2, checkInHullConstraint::T3, tol::Float64=1e-13, verbose::Bool=false) where {T1<:Function,T2<:Function,T3<:Function}
        tnodalX = nodalX'
        ec = globalToLocalGuess(xPt, tnodalX)
        # NR iteration
        dec = ones(2)
        iter = 0
        maxIter = 20
        nrm = Inf
        if verbose
                println()
        end
        while nrm > tol
                iter += 1
                if iter > maxIter
                        break
                end
                N = shapeFun(ec)
                dN = shapeFunDeriv(ec)
                dec = vec(-(tnodalX*dN)\(tnodalX*N - xPt))
                ec += dec
                nrm = smallNorm(dec)
                if verbose
                        @printf("%e\n", nrm)
                end
        end
        if iter > maxIter
                success = false
        else
                success = checkInHullConstraint(ec)
        end
        if verbose
                println(success)
        end
        return (success, ec)
end

Tri3_globalToLocal(xPt, nodalX) = globalToLocal(xPt, nodalX, Tri3_shapeFun, Tri3_shapeFunDeriv, Tri3_checkInHullConstraint) 
Tri6_globalToLocal(xPt, nodalX) = globalToLocal(xPt, nodalX, Tri6_shapeFun, Tri6_shapeFunDeriv, Tri3_checkInHullConstraint)