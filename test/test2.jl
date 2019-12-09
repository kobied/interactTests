# using CSV, DataFrames, Interact, Plots
#
#
# loadbutton = filepicker();
# columnbuttons = Observable{Any}(dom"div"());
# data = Observable{Any}(DataFrame);
# plt = Observable{Any}(plot());
# map!(CSV.read, data, loadbutton);
#
# function makebuttons(df)
#     buttons = button.(string.(names(df)))
#     for (btn, name) in zip(buttons, names(df))
#         map!(t -> histogram(df[name]), plt, btn)
#     end
#     dom"div"(hbox(buttons))
# end
#
# map!(makebuttons, columnbuttons, data);
#
# ui = dom"div"(loadbutton, columnbuttons, plt);
#
# using Blink
# w = Window()
# body!(w, ui)
#
#
# # function serverLauout(destinationPort)
# #     try
# #         WebIO.webio_serve(page("/",req -> creatGui()),destinationPort)
# #     catch e
# #         if isa(e,IOError)
# #             # sleep and then try later
# #             sleep(0.1)
# #             serverLauout(destinationPort)
# #         else
# #             throw(e)
# #         end
# #     end
# # end
# #
# # serverLauout(8000)


using Interact, DifferentialEquations, Latexify, Plots, WebIO
gr()

"""
A function which simulates and plots an ODE.
The system is first equilibrated for an input value of 1.
The plotted dynamics is the relaxation of the system after the input is changed to 10.
"""
function plotODE(ode, parameters, plotvars, initcond)
    tspan = (0.,100.)
    prob = ODEProblem(ode, initcond, tspan, parameters)
    sol = solve(prob)

    plot(
    plot(sol, vars=(:v, :w), xlabel="v", ylabel="w", title="Phase plot"), # make the phase plot
    plot(sol, vars=(:t, :v, :w), legend=:none, title="Phase(t)"),   # plot phase vs time
    plot(sol, title="FHN solution", xlabel="Time"), # plot the solution versus time
    layout=@layout [a b c]
    )

end

"""
Automatically generate sliders for all the ODE's parameters and map the results
to the plotODE function.
"""
function interactivePlot(ode, initcond)
    display(latexalign(ode))
    params = [slider(round.(exp10.(range(-1, stop=2, length=101)), sigdigits=3), label=latexify(p)) for p in ode.params]
    plotvars = ode.syms
    display(hbox(vbox(params...)))
    map((x...)->plotODE(ode, collect(x[1:end-1]), x[end], initcond),params..., plotvars)
end

"""
Define some ODEs
"""
ode1 = @ode_def NegativeFeedback begin
    dx = r_x * (e_x * input * y - x)
    dy = r_y * (e_y / x - y)
end input r_x e_x r_y e_y


ode2 = @ode_def IncoherentFeedForward begin
    dx = r_x * (e_x * input - x)
    dy = r_y * (e_y * input / x - y)
end input r_x e_x r_y e_y


ode3 = @reaction_network InducedDegradation begin
    (input*r_bind, r_unbind), X_free ↔ X_bound
    (p_free, d_free), 0 ↔ X_free
    d_bound, X_bound --> 0
end input r_bind r_unbind p_free d_free d_bound
