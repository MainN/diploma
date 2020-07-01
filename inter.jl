using Blink
using Gen
using Plotly
using Interact
using StatsPlots
using Distributions
using CSV
using DataFrames
using Tables
function maps1()
    marker = attr(size=[20, 30, 15, 10],
                  color=[10, 20, 40, 50],
                  cmin=0,
                  cmax=50,
                  colorscale="Greens",
                  colorbar=attr(title="Some rate",
                                ticksuffix="%",
                                showticksuffix="last"),
                  line_color="black")
    trace = scattergeo(;mode="markers", locations=["FRA", "DEU", "RUS", "ESP"],
                        marker=marker, name="Europe Data")
    layout = Layout(geo_scope="europe", geo_resolution=50, width=500, height=550,
                    margin=attr(l=0, r=0, t=10, b=0))
    plot(trace, layout)
end
@gen function model(data::Matrix{Float64},time::Vector{Float64})
    delta_err=@trace(exponential(1),:delta_err)
    delta_C=@trace(exponential(1),:delta_C)
    b0=@trace(normal(0,1),:b0)
    b1=@trace(normal(0,1),:b1)
    C=@trace(normal(0,delta_C),:C)
    for t in 1:6
        for i in 1:164
            if data[i,t]!=0.0
                dset=@trace(normal(C+b0+b1*time[t],delta_err),(:dset,i,t))
            end
        end
    end
end
@gen function inference(model,xs,ys,number_of_iter)
    obsevations=Gen.choicemap()
    
end
function getData(filename::String)
    s = open(filename) do file
        inputString=readlines(file)
        len=length(inputString)-1
        matr=zeros(Float64,6,len)
        deleteat!(inputString,1)
        j=1
        for x in inputString
            i=1
            splitstring=(split(x," "))
            for y in splitstring
                
                num=tryparse(Float64,y)
                if isnothing(num)
                    matr[i,j]=0.0
                else
                    matr[i,j]=num
                end
                i=i+1
            end
            
            j=j+1
        end
        return matr
    end
    
end
data=getData("data.dat")
data=transpose(data)
sum_year5= data[1:164,1]
sum_year6= data[1:164,2]
sum_year9= data[1:164,3]
sum_year12= data[1:164,4]
sum_year15= data[1:164,5]
sum_year20= data[1:164,6]

avrg_year5=(sum(+,sum_year5)/164)
avrg_year6=(sum(+,sum_year6)/164)
avrg_year9=(sum(+,sum_year9)/164)
avrg_year12=(sum(+,sum_year12)/164)
avrg_year15=(sum(+,sum_year15)/164)
avrg_year20=(sum(+,sum_year20)/164)

med_year5=sort(data[1:164,1])[82]
med_year6=sort(data[1:164,2])[82]
med_year9=sort(data[1:164,3])[82]
med_year12=sort(data[1:164,4])[82]
med_year15=sort(data[1:164,5])[82]
med_year20=sort(data[1:164,6])[82]
for x in map(log,[avrg_year5,avrg_year6,avrg_year9,avrg_year12,avrg_year15,avrg_year20])
    println("Average in " * string(5) * " years:"*string(x))
end

for x in map(log,[med_year5,med_year6,med_year9,med_year12,med_year15,med_year20])
    println("Median in " * string(5) * " years:"*string(x))
end
times=[1,2,5,8,11,16]

persons_numbers=rand(1:164,10)
persons_data=[]
for x in persons_numbers
    append!(persons_data,[data[x,1:6]])
end

log_times=map(log,times)


plt=StatsPlots.plot([1:6],map(log,[avrg_year5,avrg_year6,avrg_year9,avrg_year12,avrg_year15,avrg_year20]),xlabel = "Average")
plt2=StatsPlots.plot([1:6],map(log,[med_year5,med_year6,med_year9,med_year12,med_year15,med_year20]),xlabel = "Median")
plt3=StatsPlots.plot([1:6],log_times,xlabel = "Log of time")
plt4=StatsPlots.plot([1:6],[persons_data])
plt5=StatsPlots.histogram([1:6],[persons_data[rand(1:10)]])
dat1=map(log,[avrg_year5,avrg_year6,avrg_year9,avrg_year12,avrg_year15,avrg_year20])
dat2=map(log,[med_year5,med_year6,med_year9,med_year12,med_year15,med_year20])
df1=DataFrame()
df1.A=1:6
df1.B=dat1
df2=DataFrame()
df2.A=1:6
df2.B=dat2
df3=DataFrame()
df3.A=1:6
df3.B=persons_data[1]

#w=Window()
#ui=vbox(hbox(dataviewer(df1),dataviewer(df2)),dataviewer(df3))
#body!(w,ui)

#readline()
plot_delta_err=Plots.plot(Exponential(1),xlabel="delta_err")
plot_delta_C=Plots.plot(Exponential(1),xlabel="delta_err")
b0=Plots.plot(Normal(0,1),xlabel="b0")
b1=Plots.plot(Normal(0,1),xlabel="b1")
distro_Plot=Plots.plot(plot_delta_err,plot_delta_C,b0,b1)
trace = Gen.simulate(model, (data,times))
constraints = Gen.choicemap()
constraints[:b0]=6
constraints[:b1]=-2
constraints[:delta_C]=1
constraints[:delta_err]=1
(new_data,_)=Gen.generate(model,(data,times),constraints)
my_table=Tables.table(get_args(new_data)[1])
open("myfile.csv", "w") do io
    CSV.write(io, my_table)
end;




#w = Window()
#body!(w, dataviewer(1:10))
#println(model(1:10))

#w = Window() 
#body!(w, maps1())
#My Fancy App!<br/><br/>
#body!(w, "<button id='gobutton'>Click me!</button>")
#loadurl(w, "http://vk.com")
#readline()
