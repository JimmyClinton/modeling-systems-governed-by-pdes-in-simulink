# Modeling Systems Governed by PDEs in Simulink

This project is ogranized as a Simulink Project. As such, the first step after cloning should be
opening the ".prj" file associated with it.

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
size of the reduced model such that the the execution time of running "top_script" goes from approximately one
day down to less than one minute.
A model order reduction app with a GUI has been provided in this project. The app and the Simulink models in 
this project save and load ROMs and their corresponding source models into MAT-files. There are a handful of 
user-tunable parameters that can be used to optimize the size of the reduced system for a target error tolerance.
 Th first action the user will want to take is to check the validity of the ROM for the source model; that is, 
check whether there have been chagnes to the source since generating the ROM. To generate a new ROM, the user 
will need to identify an acceptable allowable error compared to the source model. The frequency range range of 
interest determines the bounds for the modes to be retained after modal truncation. Choosing this range requires 
prior knowledge about the system of interest from the user. The remaining two parameters are the number of modes 
retained, corresponding to the size of the reduced system. The figures below are the results of testing modal 
truncation on the heat sink and CPU model, and they provide insights into the computational cost benefits from 
MOR as well as the tradeoffs it has with numerical accuracy. The app will generate the error plot and the user 
can then determine the optimal size of the ROM and sav it to file.


Contents:

Chip_temperature_control.prj: the Simulink project file

data: a directory containing physical component data that is needed for modeling

figures: data visualization and example manufacturer data for digitization

models: Simulink model and subsystem files

src: scripts for defining modeling parameters, generating FE matrices, and a model order reduction function

top_system.slx: top level model of complete control systems

top_script.mlx: MATLAB live script that calls subsytem scripts, runs simulations with different input scenarios, and opens Simulation Manager

Demo_description.pdf: Detailed write-up of model development and design decisions made
