%%% StateMachine: record the state corresponding to the state code
% new remote host(0) -> transmit info -> info (1) ->  check the MD5 of info
% -> correct info ready to receive jobs(2) -> assign jobs -> have
% the jobs to do(3) -> do and obtain the results -> jobs obtained(4) -> check MD5 ->
% ready to receive jobs(2)





classdef StateMachine < handle
    properties
        WorkerIP
        WorkerNum
        state

        Jobs
        Results
    end
    
    methods
        function obj = StateMachine()
            obj.WorkerIP = {};
            obj.state = {};
            obj.WorkerNum = 0;
            obj.Jobs = {};
            obj.Results = {};
        end
        
        function AddWorker(obj, IP)
            obj.WorkerNum = obj.WorkerNum + 1;
            obj.WorkerIP{obj.WorkerNum} = IP;
            obj.state{obj.WorkerNum} = 0;
        end
        
        % locate the state index for IP, otherwise, return -1
        function po = ip2index(obj, IP)
            po = -1;
            for i = 1:length(obj.WorkerIP)
                if strcmp(obj.WorkerIP{i}, IP) == 1
                    po = i;
                    break;
                end
            end
        end
        
        
        % is exist
        function exist = IsExist(obj, IP)
            po = obj.ip2index(IP);
            if po == -1
                exist = 0;
            else
                exist = 1;
            end
        end
        
        % find the state for IP, otherwise return -1
        function s = ip2state(obj, IP)
            po = obj.ip2index(IP);
            if po == -1
                s = -1;
            else
                s = obj.state{po};
            end
            
        end
        
        % update the state
        function UpdateState(obj, IP, new_state)
            po = obj.ip2index(IP);
            if po == -1
                success = 0;
            else
                obj.state{po} = new_state;
                sucess = 1;
            end
        end
        
        function success = RecordJobs(obj, IP, jobs)
            po = obj.ip2index(IP);
            if po == -1
                success = 0;
            else
                obj.Jobs{po} = jobs;
                success = 1;
            end
        end
        
        
        function success = RecordResults(obj, IP, results)
            po = obj.ip2index(IP);
            if po == -1
                success = 0;
            else
                obj.Results{po} = results;
                success = 1;
            end
        end
        
        function res = GetJobs(obj, IP)
            po = obj.ip2index(IP);
            if po == -1
                res = 0;
            else 
                res = obj.Jobs{po};
            end
        end
        
        function res = GetResults(obj, IP)
            po = obj.ip2index(IP);
            if po == -1
                res = 0;
            else 
                res = obj.Results{po};
            end
        end
        
        
    end
end