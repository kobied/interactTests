# # Interactive simple plot example
# this exmaple uses Interact to build a GUI to plot data parsed from
# CSV file to DataFrame variable.
# the documentation was writen using the Literate and Weave Pkg

# ### load needed Pkg:
# `CSV` - to read the CSV file and parse the data to DataFrame variable [`for more info see docs`](https://juliadata.github.io/CSV.jl/stable/)
#-
# `DataFrames` - Pkg to work with DataFrames [`for more info see docs`](https://juliadata.github.io/DataFrames.jl/stable/)
#-
# `Interact` - Pkg tio create the GUI [`for more info see docs`](https://juliagizmos.github.io/Interact.jl/latest/)
#-
# `Plots` - Pkg to plot the data [`for more info see docs`](http://docs.juliaplots.org/latest/)

using CSV, DataFrames, Interact, Plots

# ### define the Observables for the Interact GUI
loadbutton = filepicker() # file explorer GUI, the output is the file path
columnbuttons = Observable{Any}(dom"div"()) #
data = Observable{Any}(DataFrame) #
plt = Observable{Any}(plot()) #
dropdown_x = Observable{Any}(dom"div"()) #
dropdown_y = Observable{Any}(dom"div"()) #

# ### using the map!(function, destination, collection...) function
# in this case the map! takes the 'loadbutton' which holds the CSV file name
# and pipe it to the CSV.read function which parse the file into DataFrame
# variable data
map!(CSV.read, data, loadbutton)

"""
$(SIGNATURES)

this function build the buttons of all the DataFrame columns
#Inputs
    * df - parsed data from CSV file into DataFrame format
"""
function makebuttons(df)
    buttons = button.(string.(names(df)))
    for (btn, name) in zip(buttons, names(df))
        map!(t -> histogram(df[name]), plt, btn)
    end
    dom"div"(hbox(buttons))
end

# this map! each column in data to columnbuttons variable using the 'makebuttons'
# function defined earlier
map!(makebuttons, columnbuttons, data)

# create the ui interface witch has virtecly aranged:
# 1. loadbutton
# 2. columnbuttons
# 3. plt
ui = dom"div"(loadbutton, columnbuttons, plt)

# open the GUI window
w = Window()

# parse the ui into the window
body!(w, ui);
