using Gen
using LinearAlgebra
@gen function line_model(xs::Vector{Float64})
    n = length(xs)
    slope = @trace(normal(0, 1000), :slope)
    intercept = @trace(normal(0, 2000), :intercept)
    for (i, x) in enumerate(xs)
        @trace(normal(slope * x + intercept, 0.1), (:y, i))
    end
    return n
end;
@gen function spline_model(xs::Vector{Float64})
    n = length(xs)
    slope = @trace(mvnormal(zeros(n),Diagonal(1000*ones(6))), :slope)
    intercept = @trace(normal(0, 2000), :intercept)
    @trace(mvnormal(polinome(slope,xs) .+ intercept, 0.1), (:y))
    
    
end
function polinome(slope,xs)
    n=length(xs)
    ret_val=[]
    ys=[]
    for x in xs
        for pow in 1:n
            push!(ret_val,x^n-pow+1)
        end
        push!(ys,dot(ret_val,slope))
        ret_val=[]
    end
    println(ys)
    return ys
end
xs=[1,2,5,8,11,16]
ys = [386,249,108,66,67,59]
trace = Gen.simulate(line_model, (xs,))
trace_spline = Gen.simulate(spline_model, (xs,))
println(trace_spline[(:y)])
observations = Gen.choicemap()
observations[(:y)] = ys
(trace, _) = Gen.importance_resampling(spline_model, (xs,), observations, 10000000)
println(trace[:slope]," ",trace[:intercept])
println(polinome(trace[:slope],xs))