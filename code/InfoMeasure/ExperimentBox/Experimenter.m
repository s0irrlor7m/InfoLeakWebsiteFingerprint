classdef Experimenter < handle

    properties
        machine_name
    end
    
    methods
        
        
        function batchToName(obj, batch)

            % to be implemented
        end
        
        function batches = initBatches(obj)
 
            % should be implemented by individual experiment
        end
        
        function ServerDoWork(obj, pm, server_idx)

            % to be implemented by individual experiment
        end  
        
        
        function obj = Experimenter()
  
            mname = char(java.net.InetAddress.getLocalHost.getHostName);
            obj.machine_name = mname;
        end


        function new_batches = unfinishedBatch(obj)
    
            batches = obj.initBatches();
            new_batches{2} = batches{2};
            batch_count = 1;
            
            for i = 1:length(batches{1})
                % for each batch
                batch = batches{1}{i};
                                
                path = strcat('debug_data/', obj.machine_name ,'/JobRecord_', obj.batchToName(batch), '.mat');
                is_valid = ValidateJobRecord(path);
                                
                % update new_batch if invalid                
                if is_valid == 0
                    new_batches{1}{batch_count} = batch;
                    batch_count = batch_count + 1;
                end 
            end
        end
        

        
        
        function execute(obj)
             
            param = obj.unfinishedBatch();
            WrapperScheduler('create', param);
            
            % start infoDistributor  
            port_num = readParam('port_number'); 
            nserver = readParam('server_number');
            
            % run infoDistributorManager
            if readParam('infoDistributorManager')
                runtime = java.lang.Runtime.getRuntime();
                command = strcat('matlab -nodisplay -r addpath(''../parallel_measure/'');addpath(''../ToolBox/util/'');infoDistributorManager(', num2str(port_num+1), ')');
                proc = runtime.exec(command);
            end

            % start do jobs
            while ~WrapperScheduler('isFinished')
                % call scheduler to get parameters to work on
                bidx = WrapperScheduler('popBatchIdx');
                if length(bidx) ~= 0
                    % have job to do
                    pm = WrapperScheduler('getBatch', bidx);
                    obj.ServerDoWork(pm, 1);
                    WrapperScheduler('finishBatch', bidx);
                end
                WrapperScheduler('updateTimer');
            end
            WrapperScheduler('exit');

            % close infoDistributorManager
            if readParam('infoDistributorManager')
                proc.destroy();
            end
        end
        
    end
    

end
