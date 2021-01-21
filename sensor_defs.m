%% temperature sensors
tauTemp = 15; % seconds
[sA,sB,sC,sD] = tf2ss([1],[tauTemp 1]);