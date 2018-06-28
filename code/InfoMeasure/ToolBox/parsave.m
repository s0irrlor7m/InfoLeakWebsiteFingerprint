function parsave(fname, x)
    sprintf('before: %d-%d', fname); 
    path = GetPath(fname);
    if exist(path) ~= 2
      save(path, 'x');
    elseif fname(2) ~= 1
      fname = GetEmptyPos(fname);
      path = GetPath(fname);
      save(path, 'x');
    else
      ;
    end
    sprintf('after: %d-%d', fname);
end






function path = GetPath(fname)
    DST = 'debug_indiv/';
    path = strcat(DST, 'f', int2str(fname(1)), '-', 'b', int2str(fname(2)), '.mat');
end



function fn = GetEmptyPos(fname)
    for counter = 2:100
      path = GetPath([fname(1), counter]);
      if exist(path) ~= 2
        fn = [fname(1), counter];
        break;
      end
    end
end
