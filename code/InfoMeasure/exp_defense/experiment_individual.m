classdef experiment_individual < Experimenter

    properties
    end
    
    methods
        
        function ftag = batchToName(obj, batch)

            ftag = strcat(batch{1}, '_fidx', int2str(batch{2}), '_iter', int2str(batch{3}));
        end
        
        function param = initBatches(obj)
            
            % this is where to configure servers' jobs
            % 1st: exp tag (buflo_5 buflo_10, ...)
            % 2st: feature index
            % 3rd: counter for each measurement
            
%		exp_tag = {'buflo_5', 'buflo_10', 'buflo_20', 'buflo_30', 'buflo_40', 'buflo_50', 'buflo_60', 'buflo_80', 'buflo_100', 'buflo_120'};
			exp_tag = {'buflo_40'};
            
            batch_idx = 1;
            timeout = 8000;
            iter = 1;
            for e = 1:length(exp_tag)
				for i = 1:3043
					for j = 1:iter
						batch = {exp_tag{e}, i, j};
						param{1}{batch_idx} = batch;
						batch_idx = batch_idx + 1;
					end
				end
			end
            
            
            param{2} = timeout;

        end
        
        function ServerDoWork(obj, batch, server_id)

            % server specific setup
            port_number = readParam('port_number') + server_id;
            
            % read parameters
            exp_tag = batch{1};
            fidx = batch{2};
            iter = batch{3};
            
            % generate vec, accordingly
            vec = zeros(1,3043);
            vec(fidx) = 1;
            
            % dataset path
            % generate dataset path, feed by argMap parameter
            Dataset_path = '*************************';
            monitor_dataset = strcat(Dataset_path, exp_tag, '/');
            argMap = containers.Map();
            argMap('monitor_dataset') = monitor_dataset;
            
            
            % build the model
            info = model_init(vec, 0, 0, argMap);
           
            disp(batch);
            disp('finished model building...')
            
            ftag = obj.batchToName(batch);
            is_success = server(info, ftag, port_number);
            
            
        end
    end
    
    
end
