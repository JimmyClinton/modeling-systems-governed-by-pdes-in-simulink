%% initialization script
%heat_sink_defs_DEBUG
heat_sink_defs
fan_defs
sensor_defs
%% sweep
mdl = 'top_system';
load_system(mdl);
nSims = 6;
in(1:nSims) = Simulink.SimulationInput(mdl);
for i = 1:nSims
    in(i) = setBlockParameter(in(i),[mdl '/Heat Generation'], ...
                                'ActiveScenario', ['Scenario' num2str(i)]);
end
out = parsim(in,'TransferBaseWorkspaceVariables','on');
openSimulationManager(in,out)
