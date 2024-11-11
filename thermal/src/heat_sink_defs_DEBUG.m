%% heat sink
heatsink = createpde('thermal','transient');
%% heat sink+chip geometry
L = 15e-3; % m
R1 = [3 4 0.0 L L 0.0 0.0 0.0  L  L]'; % top cube
R2 = [3 4 0.0 L L 0.0 0.0 0.0 -L -L]'; % bot cube
gd = [R1 R2];
sf = 'R1+R2';
ns = (char('R1','R2'))';

g  = decsg(gd,sf,ns); % Decompose constructive solid 2-D geometry into minimal regions
pg = geometryFromEdges(heatsink,g); % apply geometry to model
gm = extrude(pg,L); % generate 3D geometry from 2D cross section
heatsink.Geometry = gm; % replace model geometry with 3D
m = generateMesh(heatsink,'Hmin',5e-3); % try to min(nDoF)
%% visualize geometry to get i/o #s
% figure; pdegplot(heatsink,'FaceLabels','on') % visualize geometry
% figure; pdegplot(heatsink,'CellLabels','on')
% figure; pdemesh(m); axis equal
% figure; pdemesh(m,'NodeLabels','on') % visualize mesh
CPUcell = 1;
freeBCfaces = [1 3 6 8 10]; % faces that do not see flow, using free convection
forcedBCfaces = [2 4 5 9 11]; % faces aligned with flow
outID = 7; % top right corner
%% internal properties
k = 210; % W*m^-1*K^-1
rho = 2710; % kg/m^3
Cp = 900; % J*kg^-1*K^-1
mtl = thermalProperties(heatsink,'ThermalConductivity',k, ...
                                 'MassDensity',rho, ...
                                 'SpecificHeat',Cp); % aluminum alloy 6060 T6
chipHeat = 1; % Watts
chipW = L; % m
chipL = L; % m
chipH = L; % m
heatPerVol = chipHeat/(chipL*chipW*chipH); % W/m^3
heatSource = internalHeatSource(heatsink,heatPerVol,'Cell',CPUcell);
IC = 294; % Kelvin
thermIC = thermalIC(heatsink,IC); % T = IC everywhere @T=0
%% boundary conditions
Tinf = IC; % ambient temperature, Kelvin
xSectionA = (2*L)^2; % duct cross-sectional area, m^2
rho = 1.225; % kg/m^3
h_free = 9.0;
h_forced = [ ...
0.0, h_free; ...
3.0, 50.0; ...
]; % [V_induced, convective heat transfer coeff]
h_forced(:,1) = h_forced(:,1) * xSectionA * rho; % convert to h = f(mdot)
freeBC = thermalBC(heatsink,'Face',freeBCfaces,'HeatFlux',1); % used as convective BC
forcedBC = thermalBC(heatsink,'Face',forcedBCfaces,'HeatFlux',1); % used as convective BC
%% FE formulation
femat = assembleFEMatrices(heatsink);
K = femat.K; % is the stiffness matrix, the integral of the c coefficient against the basis functions
M = femat.M; % is the mass matrix, the integral of the m or d coefficient against the basis functions.
A = femat.A; % is the integral of the a coefficient against the basis functions.
F = femat.F; % is the integral of the f coefficient against the basis functions.
Q = femat.Q; % is the integral of the q boundary condition against the basis functions.
G = femat.G; % is the integral of the g boundary condition against the basis functions.
H = femat.H; % The H and R matrices come directly from the Dirichlet conditions and the mesh.
R = femat.R; % %
%% construct SL vectors
nDoF = size(K,1);
freeBCnodes = findNodes(m,'Region','Face',freeBCfaces);
unitFreeBC = zeros(nDoF,1);
unitFreeBC(freeBCnodes) = 1;
normalizedFreeBC = zeros(nDoF,1);
normalizedFreeBC(freeBCnodes) = G(freeBCnodes);
forcedBCnodes = findNodes(m,'Region','Face',forcedBCfaces);
unitForcedBC = zeros(nDoF,1);
unitForcedBC(forcedBCnodes) = 1;
normalizedForcedBC = zeros(nDoF,1);
normalizedForcedBC(forcedBCnodes) = G(forcedBCnodes);
unitCPUHeat = full(F);