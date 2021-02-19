%% access parent directory files
addpath ..
%% full nDoF
heat_sink_defs
n = size(K,1);
An = Q+K;
Bn = speye(n);
Cn = speye(n);
Dn = sparse(n,n);
En = M;
%% parameters for simulations
dt = 0.1;
tend = 10;
outID = 1;
meanvec = zeros(n,1);
varvec = (0.1).*ones(n,1);
seed = 1;
ICvec = IC*ones(n,1);
mdl = 'test_model';
blk = [mdl '/Descriptor State-Space'];
load_system(mdl)
%% parameters for MOR
freq = [-Inf 2e2];
r = [2 4 8 16 32 64 128 256 512];
nr = length(r);
dssMats = cell(nr,6);
%% parameters for post-processing
nt = length(0:dt:tend);
timing = zeros(1,nr);
error = zeros(1,nr);
yout = zeros(nr,nt);
normtype = 'fro'; % either double value 1,2,Inf or string 'fro'
%% first, get baseline data
set_param(blk,'E','En','A','-An','B','Bn','C','Cn','D','Dn',...
                                                   'InitialCondition','IC')
disp(['Starting simulation @ ' datestr(now,'HH:MM:SS')])
out = sim(mdl);
fprintf('Simulation took %f seconds\n', ...
                    out.SimulationMetadata.TimingInfo.TotalElapsedWallTime)
baseline = out.yout;
tout = out.tout;
%% construct reduced matrices
disp(['Starting MOR @ ' datestr(now,'HH:MM:SS')])
for i = 1:nr
    [dssMats{i,1}, ...
     dssMats{i,2}, ...
     dssMats{i,3}, ...
     dssMats{i,4}, ...
     dssMats{i,5}, ...
     dssMats{i,6}] = reduceModelOrder(An,Bn,Cn,Dn,En,freq,r(i));
    disp(['Done with k = ' num2str(r(i)) ' @ ' datestr(now,'HH:MM:SS')])
end
%% simulate test space
disp(['Starting sims @ ' datestr(now,'HH:MM:SS')])
for i = 1:nr
    set_param(blk,...
    'A',['-dssMats{' num2str(i) ',1}'],...
    'B',['dssMats{' num2str(i) ',2}'],...
    'C',['dssMats{' num2str(i) ',3}'],...
    'D',['dssMats{' num2str(i) ',4}'],...
    'E',['dssMats{' num2str(i) ',5}'],...
    'InitialCondition',['dssMats{' num2str(i) ',6}''*ICvec'])
    outij = sim(mdl);
    timing(i) =  outij.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
    yout(i,:) = outij.yout;
    error(i) = norm(baseline-outij.yout,normtype)/ ...
                                               norm(baseline,normtype);
    disp(['Done with k = ' num2str(r(i)) ' @ ' datestr(now,'HH:MM:SS')])
end
%% post-processing
figure; plot(r,error,'-*','LineWidth',2)
xlabel('Reduced Order')
ylabel('Relative Error')
%% restore path
rmpath ..