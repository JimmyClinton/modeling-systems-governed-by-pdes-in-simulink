function results = getTransientResults(tMdl,tBlk,tSys)
    load_system(tMdl);
    N0 = size(tSys.B,2);
    assignin('base','N0',N0);
    assignin('base','tSys',tSys);
    assignin('base','tBlk',tBlk);
    set_param(tBlk,'E','tSys.E',...
                  'A','-tSys.A',...
                  'B','tSys.B',...
                  'C','tSys.C','D','tSys.D');
    results = sim(tMdl);
    close_system(tMdl);
end