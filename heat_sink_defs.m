%% heat sink
heatsink = createpde('thermal','transient');
%% heat sink+chip geometry
W = 27*10^-3; % heat sink width
H = 17.5*10^-3; % heat sink fin height
t = 2*10^-3; % approximated fin thickness
nFin = 8; % number of fins on heat sink
dFin = (W - (nFin*t))/(nFin-1); % space between fins, calculated from approximations
R1 = [3 4 0.0 W W 0.0 0.0 0.0 t t]'; % base plate
R2 = [3 4 (0*(t+dFin)) (0*(t+dFin))+t (0*(t+dFin))+t (0*(t+dFin)) t t H-t H-t]'; % fin1
R3 = [3 4 (1*(t+dFin)) (1*(t+dFin))+t (1*(t+dFin))+t (1*(t+dFin)) t t H-t H-t]'; % fin2
R4 = [3 4 (2*(t+dFin)) (2*(t+dFin))+t (2*(t+dFin))+t (2*(t+dFin)) t t H-t H-t]'; % fin3
R5 = [3 4 (3*(t+dFin)) (3*(t+dFin))+t (3*(t+dFin))+t (3*(t+dFin)) t t H-t H-t]'; % fin4
R6 = [3 4 (4*(t+dFin)) (4*(t+dFin))+t (4*(t+dFin))+t (4*(t+dFin)) t t H-t H-t]'; % fin5
R7 = [3 4 (5*(t+dFin)) (5*(t+dFin))+t (5*(t+dFin))+t (5*(t+dFin)) t t H-t H-t]'; % fin6
R8 = [3 4 (6*(t+dFin)) (6*(t+dFin))+t (6*(t+dFin))+t (6*(t+dFin)) t t H-t H-t]'; % fin7
R9 = [3 4 (7*(t+dFin)) (7*(t+dFin))+t (7*(t+dFin))+t (7*(t+dFin)) t t H-t H-t]'; % fin8
R0 = [3 4 0.001 0.026 0.026 0.001 0.0 0.0 -t -t]'; % chip
gd = [R1 R2 R3 R4 R5 R6 R7 R8 R9 R0]; % Geometry description matrix
sf = 'R1+R2+R3+R4+R5+R6+R7+R8+R9+R0'; % Set formula for adding 2D shapes
ns = (char('R1','R2','R3','R4','R5','R6','R7','R8','R9','R0'))'; % Name-space matrix
g  = decsg(gd,sf,ns); % Decompose constructive solid 2-D geometry into minimal regions
pg = geometryFromEdges(heatsink,g); % apply geometry to model
gm = extrude(pg,W); % generate 3D geometry from 2D cross section
heatsink.Geometry = gm; % replace model geometry with 3D
m = generateMesh(heatsink,'Hmin',t,'Hgrad',1.9); % try to min(nDoF)
%% visualize geometry to get i/o #s
% figure; pdegplot(heatsink,'FaceLabels','on') % visualize geometry
% figure; pdegplot(heatsink,'CellLabels','on')
% figure; pdemesh(m); axis equal
% figure; pdemesh(m,'NodeLabels','on') % visualize mesh
CPUcell = 1;
freeBCfaces = 1:20; % faces that do not see flow, using free convection
forcedBCfaces = 21:heatsink.Geometry.NumFaces; % faces aligned with flow
outID = findNodes(m,'nearest',[0.026 -t/2 W/2]'); % middle of yz side of casing
%% internal properties
k = 210; % W*m^-1*K^-1
rho = 2710; % kg/m^3
Cp = 900; % J*kg^-1*K^-1
mtl = thermalProperties(heatsink,'ThermalConductivity',k, ...
                                 'MassDensity',rho, ...
                                 'SpecificHeat',Cp); % aluminum alloy 6060 T6
chipHeat = 1; % Watts
chipW = 25e-3; % m
chipL = W; % m
chipH = t; % m
heatPerVol = chipHeat/(chipL*chipW*chipH); % W/m^3
heatSource = internalHeatSource(heatsink,heatPerVol,'Cell',CPUcell);
IC = 294; % Kelvin
thermIC = thermalIC(heatsink,IC); % T = IC everywhere @T=0
%% boundary conditions
Tinf = IC; % ambient temperature, Kelvin
xSectionA = (2*W)*(2*H); % duct cross-sectional area, m^2
rho = 1.225; % kg/m^3
h_free = 9.0;
h_forced = [ ...
0.0, h_free; ...
3.0, 50.0; ...
]; % [V_linear, convective heat transfer coeff]
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
x0 = ones(nDoF,1)*IC;
unitCPUHeat = full(F);