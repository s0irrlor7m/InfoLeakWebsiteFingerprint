% scheduler
% generic form to schedule jobs, servers, etc

% status:   0   available; 
%           >0  in process;
%           -1  finished

% prerequisite, addpath semaphore!

classdef Scheduler < handle

properties
    batchList
    batchListStatus
    batchListTimer
    numBatch
    
    Tthres
    

end

methods
    
    function obj = Scheduler(param)
        obj.batchList = param{1};
        obj.numBatch = length(obj.batchList);
        obj.batchListStatus = zeros(1,obj.numBatch);
        obj.Tthres = param{2}; 
    end
    
    function resetBatch(obj, bidx)
        obj.batchListStatus(bidx) = 0;
    end
    
    % pop a batch (containing parameters)
    % return batch idx
    function res = popBatchIdx(obj)
        res = [];
        for i = 1:obj.numBatch
            if obj.batchListStatus(i) == 0
                % find a available batch to work on
                res =  i;
                obj.batchListStatus(i) = 1;
                obj.batchListTimer{i} = clock;
                break;
            end
        end
    end
    
    function res = getBatch(obj, bidx)
        res = obj.batchList{bidx};
    end
    
    % is finished 
    function res = isFinished(obj)
        res = 1;
        for i = 1:obj.numBatch
            if obj.batchListStatus(i) ~= -1
                res = 0;
                break;
            end
        end
    end
    
    % if finish a batch, update
    function finishBatch(obj, bidx)
        obj.batchListStatus(bidx) = -1;
    end
    
    % update timer, if a batch timeout, reset its status
    function updateTimer(obj)
        for i = 1:obj.numBatch
            if obj.batchListStatus(i) > 0
                % in process batch, check if timeout
                st_clock = obj.batchListTimer{i};
                now_clock = clock;
                if etime(now_clock, st_clock) > obj.Tthres
                    % if timeout, resetbatch
                    obj.resetBatch(i);
                end
            end
        end
    end
    
    
    
    
        
    end
    
end

