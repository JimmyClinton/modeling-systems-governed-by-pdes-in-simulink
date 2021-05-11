%% temperature sensors
tauTemp = 1.0; % seconds
[sA,sB,sC,sD] = tf2ss([1],[tauTemp 1]);