using Gen
using Blink
using Plotly
using Interact
using Distributions
using CSV
using LinearAlgebra
function gauss(sigma,mu) 
    data=collect(mu-(sigma*sqrt(2*pi)):0.0001:mu+(sigma*sqrt(2*pi)))
    #((1/sigma*sqrt(2*pi))*(Base.MathConstants.e^((-0.5)*((x-mu)/sigma)^2)))
    new_data=map(x->((Base.MathConstants.e^((-(x-mu)^2))/(2*sigma^2))/(sigma*sqrt(2*pi))),data)
    println(new_data)
    return new_data
end
function getrange(left,right,number_of_steps)
    return abs(right-left)/number_of_steps
end
d = Normal(0, 1)
r = range(-3, 3; length = 100)
global window = Window()
x=[-5.0, -4.0, -3.0, -0.2, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
y=[-5.0, -4.0, -3.0, -0.2, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
res_distr=gauss(1,5)
trace = Plotly.scatter(y=x,mode="markers")
trace2 = Plotly.scatter(y=5*y,mode="line")
distr_trace = Plotly.scatter(x=r,y=pdf.(d, r),mode="line")
distr_trace2 = Plotly.scatter(x=[],y=[],mode="line")
p = Plotly.plot()
function updateplot(i)
    global x[1] = i*x[1]
    println(x)
    restyle!(p, 1,x=[x] )
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
function updateDistro(i)
    (sigm,m)=(sigma[], mu[])
    (sigm,m)=(parse(Float64,sigm),parse(Float64,m))
    distro=Normal(sigm,m)
    r = range(-3, 3; length = 100)
    trace = Plotly.scatter(x=r,y=pdf.(distro, r),mode="line")
    Plotly.deletetraces!(p,0)
    Plotly.addtraces!(p,trace)
    
end
function pri(o)
    if o=="Данные"
        ui=dom"div"(wdg,vbox(file, p))
        body!(window,ui)
    end
    if o=="Параметры модели"
        ui=dom"div"(wdg,vbox(hbox(sigma,mu), p,b))
        body!(window,ui)
    end
end
@gen function model(xs)
    slope = @trace(normal(0, 1000), :slope)
    intercept = @trace(normal(0, 2000), :intercept)
    for (i, x) in enumerate(xs)
        @trace(normal(slope * x + intercept, 0.1), (:y, i))
    end   
end
function interference(yes)
    choices=Gen.choicemap()
    counter=1
    for j in yes
        Gen.set_value!(choices,(:y,counter),j)
        counter=counter+1
    end
    trace3,=Gen.generate(model,([1,2,5,8,11,16],),choices)
    for iter in 1:1500
        trace3,acc=Gen.mh(trace3,select(:slope,:intercept))
    end
    return(trace3[:slope],trace3[:intercept])
end

function data_csv(filename)
    global data_matrix
    data_matrix=CSV.read(filename)
    
    drop=dropdown(1:length(data_matrix[:,1]))
    on(plot_csv,drop)
    new_data=[]
    for x in data_matrix[1,:]
        if x!="NA"
            append!(new_data,parse(Float64,x))
        else
            append!(new_data,0)
        end
        
    end
    slope,intercept=interference(new_data)

    new_yes=[]

    for x in [1,2,5,8,11,16]
        push!(new_yes,intercept+slope*x)
    end
    trace = Plotly.scatter(x=["1","2","5","8","11","16"],y=new_data,mode="markers")
    new_trace = Plotly.scatter(x=["1","2","5","8","11","16"],y=new_yes,mode="line")
    Plotly.deletetraces!(p,0,1)
    Plotly.addtraces!(p,trace,new_trace)
    ui=dom"div"(wdg,vbox(file, p),hbox(drop,number_of_lines,opti))
    body!(window,ui)
    
end
function plot_csv(param)
    current=param
    global data_matrix
    new_data=[]
    for x in data_matrix[param,:]
        if x!="NA"
            append!(new_data,parse(Float64,x))
        else
            append!(new_data,0)
        end
        
    end
    slope,intercept=interference(new_data)
    new_yes=[]
    for x in [1,2,5,8,11,16]
        push!(new_yes,intercept+slope*x)
    end
    trace = Plotly.scatter(x=["1","2","5","8","11","16"],y=new_data,mode="markers")
    new_trace = Plotly.scatter(x=["1","2","5","8","11","16"],y=new_yes,mode="line")
    Plotly.deletetraces!(p,0,1)
    Plotly.addtraces!(p,trace,new_trace)
end
function drawlines(o)
    input=parse(Float64,number_of_lines[])
    new_data=[]
    println(drop[:value])
    
    for x in data_matrix[current,:]
        if x!="NA"
            append!(new_data,parse(Float64,x))
        else
            append!(new_data,0)
        end
        
    end
    for x in 1:input
        slope,intercept=interference(new_data)
        new_yes=[]
        for elem in [1,2,5,8,11,16]
            push!(new_yes,intercept+slope*elem)
        end
        new_trace = Plotly.scatter(x=["1","2","5","8","11","16"],y=new_yes,mode="line")
        Plotly.addtraces!(p,new_trace)
    end
end
global current=1
sli = slider(1:100, label="i")
on(updateplot, sli)
global sigma=textbox("enter sigma:",label="Parametrs=")
global number_of_lines=textbox("Enter number of line to draw")
global mu=textbox("enter mu:")
global opti=button("Draw lines")
b=button("Press your cock retard")
on(updateDistro,b)
drop=dropdown([])
println(drop[:options])
file=filepicker(label="Choose a file..."; multiple=false, accept=".csv")
options = Observable(["Данные", "Параметры модели", "c"])
wdg = tabs(options)
on(pri,wdg)
on(data_csv,file)
on(drawlines,opti)

ui = dom"div"(wdg,vbox(file, p))
body!(window,ui)
readline()