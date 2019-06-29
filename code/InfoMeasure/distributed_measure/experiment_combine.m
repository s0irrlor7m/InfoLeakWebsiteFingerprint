classdef experiment_combine < Experimenter

    properties
    end
    
    methods
        
        function ftag = batchToName(obj, batch)

            ftag = strcat(batch{1}, '_category', int2str(batch{2}), '_topn', int2str(batch{3}), '_bstrap', int2str(batch{4}));
        end
        
        function param = initBatches(obj)

            % this is where to configure servers' jobs            
            % 1st:      experiment tag 
            % 2nd:      category idx (1 for overall, 2 for pkt_num, ...)
            % 3rd:	topn
            % 4th:      bootstrap_idx (0 for non-bootstrap, 1.. for bstrap idx)
            
            
            selector = GetSelector();
            
            batch_idx = 1;
            timeout = 8000;

			bstrap_num = 50;
			
%			exp_tag = {'buflo_5', 'buflo_10', 'buflo_20', 'buflo_30', 'buflo_40', 'buflo_50', 'buflo_60', 'buflo_80', 'buflo_100', 'buflo_120'};

exp_tag = {'WTF_0.1', 'WTF_0.2', 'WTF_0.3', 'WTF_0.4', 'WTF_0.5', 'WTF_0.6', 'WTF_0.7', 'WTF_0.8', 'WTF_0.9'};
			
            
            for e = 1:length(exp_tag)
				% for each exp tag
				%for i = 1:length(selector)
				for i = 1:1%length(selector)
					% for each category
					%for j = 1:length(selector{i}{2})
					for j = [max(selector{i}{2})]
						% for each topn
						for k = 0:bstrap_num
							% for bootstrap
							%batch = {exp_tag{e}, i, selector{i}{2}(j), k};
							batch = {exp_tag{e}, i, j, k};
							param{1}{batch_idx} = batch;
							batch_idx = batch_idx + 1;
						end
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
            category_idx = batch{2};
            topn = batch{3};
            bstrap_idx = batch{4};
            
            
            % generate vec, accordingly
            home_directory = readParam('home_directory',1);
            MIanalysis_path = strcat(home_directory, 'experiment/exp3.0/accuracy_info/info/', exp_tag, '/combine_measure/MIanalysis/MIanalysis_cat', num2str(category_idx), '_topn', num2str(topn), '.mat');
            m = importdata(MIanalysis_path);
            vec =m.vec;
            
            % generate dataset path, feed by argMap parameter
            Dataset_path = '***********************';
            monitor_dataset = strcat(Dataset_path, exp_tag, '/');
            argMap = containers.Map();
            argMap('monitor_dataset') = monitor_dataset;
            
            % build the model
            if bstrap_idx == 0
                % no bootstrap
                info = model_init(vec, 0, 0, argMap);
            else  
                info = model_init(vec, 1, 0, argMap);
            end
			disp(batch);
            disp('finished model building...')
            
            ftag = obj.batchToName(batch); 
            is_success = server(info, ftag, port_number);
        end
    end
    
    
end
