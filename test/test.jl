using Plots,Mux,Interact,CSV,DataFrames

function addplot(varsym,varnames)
    options = Observable{Any}(Dict{String,Symbol}()) # create an Observable var 'options' as Dict{String,Symbol}
    map((varname,varsym) -> options.val[varname] = varsym, varnames, varsym) # map the 'varnames' and 'vaesym' to 'options'
    plotvar = dropdown(options.val;label = nothing,multiple = true) # create a widget of type 'dropdown' to define the var's to plot
    # plt = Interact.@map plot(collect(-50:50),&mOutput ,label = "Model output")
end

function updateVarToPlot(datain)
    # println("updateVarToPlot function input type is : $(typeof(datain))")
    # println("updateVarToPlot function input is : $datain")
    if isa(datain,DataFrame)
        varsym = names(datain) # parse the 'DataFrame' fields names from 'data.val' as Symbol
        varnames = string.(names(datain)) # parse the 'DataFrame' fields names from 'data.val' as String
        addplot(varsym,varnames)
        # println(varsym,varnames)
    else
        varsym = nothing
        varnames = nothing
        # println("nothing")
    end
end

function createLayout()
    data = Observable{Any}(DataFrame) # create an Observible var 'data' of type 'DataFrame'
    plt = Observable{Any}(plot()) # create an Observible var 'data' of type 'DataFrame'

    loadbutton = filepicker(label = "load CSV file"; multiple = false, accept = "*.csv") #call the load file widget
    map!(CSV.read, data, loadbutton) # map the path from the 'loadbutton' to the CSV.read and save the output to 'data'
    map!(updateVarToPlot,,plt,data)
    # Interact.@map updateVarToPlot(&data)
    # Observables.onany(updateVarToPlot,data)
    # (varsym,varnames) = Observables.onany(updateVarToPlot,data)

    # addPlotButton = button(label = "Add a Plot")
    # on(_->addplot(data),addPlotButton)


    # mOutput = Interact.@map myModel(&p1s,&p2s)
    # plt = Interact.@map plot(collect(-50:50),&mOutput ,label = "Model output")
    # wdg = Widget(["p1" => p1s, "p2" => p2s, "addPlotButton" => addPlotButton, "loadFileButton" => loadFileButton], output = mOutput)
    # @layout! wdg hbox(plt,vbox(:p1, :p2, :loadFileButton, :addPlotButton))
end

function serverLauout(destinationPort)
    try
        WebIO.webio_serve(page("/",req -> createLayout()),destinationPort)
    catch e
        if isa(e,IOError)
            # sleep and then try later
            sleep(0.1)
            serverLauout(destinationPort)
        else
            throw(e)
        end
    end
end

serverLauout(8000)
