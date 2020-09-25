using Gen
using Plots
using Distributions
plotly()
Plots.PlotlyBackend()
@gen function model(xs)
    slope = @trace(normal(5, 10), :slope)
    intercept = @trace(normal(0, 10), :intercept)
    for (i, x) in enumerate(xs)
        @trace(normal(slope * x + intercept, 0.1), (:y, i))
    end   
end

function interference(yes,iters)
    choices=Gen.choicemap()
    counter=1
    for j in yes
        Gen.set_value!(choices,(:y,counter),j)
        counter=counter+1
    end
    trace3,=Gen.generate(model,([1,2,5,8,11,16],),choices)
    println(trace3)
    choices = get_values_shallow(Gen.get_choices(trace3))
    println(choices)
    choices_counter=0
    for x in choices
       choices_counter+=1 
    end
    matrix=zeros((iters,choices_counter))
    for iter in 1:iters
        trace3,acc=Gen.mh(trace3,select(:slope,:intercept))
        inner_counter=1
        for x in get_values_shallow(Gen.get_choices(trace3))

            matrix[iter,inner_counter]=x[2]
            inner_counter+=1
        end
    end
    #println(trace3[:slope]," ",trace3[:intercept])
    return(trace3[:slope],trace3[:intercept],matrix)
end
_,_,matrix=interference([1,2,5,8,11,16],1500)
weight=[]
global iter=0
global first=1
for x in matrix[:,4]
    if x in weight
        weight[iter]+=1
    else
        global iter+=1
        append!(weight,1)
    end

end
#println(matrix[:,4])
display(plot(matrix[:,4]))
#last version
readline()
display(histogram(matrix[:,4], bins = :scott, weights = repeat(1:50000, outer = 30),normalize=true))
readline()
#println(length(matrix[:,4]))