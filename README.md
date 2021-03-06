# Modeling Systems Governed by PDEs in Simulink

The system being modeled in this Simulink example is a variable-speed fan cooling a CPU which,
depending on the model and the operating point, can generate variable amount of heat. Each component
of the system is modeled using techniques that  easily incorporate empirical data and technical
specifications, and all assumptions are stated in the following discussion regarding levels of
modeling fidelity.

The plant in this system is the thermal dynamics of the heat-generating CPU and the heat-dissipating heat
sink. These dynamics are modeled by a finite element formulation of the heat equation on the 3D
geometry. The geometry, meshing, and discretization in this example are done using MATLAB’s PDE
Toolbox. The finite element matrices generated can then be solved using Simulink’s Descriptor State Space
block. For more information on time-dependent finite-element formulations, please see the MathWorks
documentation.
The dominant mode of heat transfer in this scenario is due to convection. A convective boundary condition
is constructed in Simulink for the ducted airflow where forced convection coefficients 
would be applied on the internal fin surfaces, and free convection coefficients are applied on the
external facing surfaces of the system.
The heat generation of the CPU can be controlled by the user in this formulation as an input Wattage. This
demonstration provides examples of different loadings of the processor that lead to different heat
generation, thus lending itself useful for design decisions in determining if a certain heat sink is suitable
for a specific CPU.

# Running the Model

This example is organized inside a Simulink Project. Once the project is opened, running “top_script” will
load all the variables needed for the simulation and then execute a parameter sweep. Six scenarios are
included in this example. The six simulations run varied levels of heat generation from the CPU as input
to the plant subsystem.
Upon completion of the parameter sweep, the Simulation Manager will launch. The socket temperature
signal is logged using Simulink Data Inspector and can be visualized by selecting the simulations of
interest and clicking the “Show Results” option. The Signal Editor block, data logging, and adding
additional systems to the model can all provide opportunities to expand on physical system modeling
and the engineering design decision process that goes along with it.
Note, there is an included “debug” plant model that uses the same parameters, but a simpler geometry
with fewer mesh nodes to reduce the number of degrees of freedom. This is useful for debugging the
model and iterating on other parameters in the system outside of the plant. This feature can be utilized
by commenting out “heat_sink_defs” in the “top_script” and replacing it with “heat_sink_defs_DEBUG”.

# Release 2.0: Model Order Reduction

This example using a finite element formulation of the heat equation on the heat sink is quite computationally
intensive, requiring matrix equations of size 18,559 x 18,559. This method therefore naturally presents an
opportunity to apply a model order reduction technique in order to reduce the resources needed to simulate. An
option to choose between the full-order finite element model or a reduced-order version of the FE model was
added in the "Choose fidelity" block in the CPU + Heat Sink subsystem. The user now has an option to choose the
size of the reduced model such that the the execution time of running "top_script" goes from the order of one
day down to the order of one minute.
The directory "MOR_tests" contains a test script that examines the relative error of reduced order models as a
function of reduced order as well as other model order reduction parameters.
The model order reduction parameters appear when "Reduced Order Model" is chosen from the drop down menu in the
"Choose fidelity" block in the plant subsytem. The first parameter chosen by the user is a frequency range range
of interest for the modes to be retained after modal truncation. Choosing this range requires prior knowledge
about the system of interest from the user. The remaining two parameters are the number of modes retained,
corresponding to the size of the reduced system.

Contents:

Chip_temperature_control.prj: the Simulink project file

CFMvsRPM.csv, RPMvsV.csv: data tables used to construct 1D lookup tables in Simulink model, can be digitized data from plots

fan.slx, heat_sink.slx, sensor.slx: subsystem files referenced by the top level model

fan_defs.m, heat_sink_defs.m, heat_sink_defs_DEBUG.m, sensor_defs.m: MATLAB scripts to initialize subsystem parameters

top_system.slx: top level model of complete control systems

HeatInput.mat: MAT file that defines Signal Editor scenarios

top_script.m: MATLAB script that calls subsytem scripts, runs simulations with different input scenarios, and opens Simulation Manager

Demo_description.pdf: Detailed write-up of model development and design decisions made

MOR_tests: directory that contains script to determine acceptable reduced order model