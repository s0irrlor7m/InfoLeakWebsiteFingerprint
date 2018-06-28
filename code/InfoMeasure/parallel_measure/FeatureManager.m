function res = FeatureManager(status, clock, param1)

% 0 denotes available
% -1 denotes done
% first cell to denote state
% second cell to denote clock 

thres = readParam('feature_timeout');
key = 123;

res = 0;
mname = char(java.net.InetAddress.getLocalHost.getHostName);
data_path = strcat('../', readParam('debug_data',1),'/', mname, '/');
FeatureList_path = strcat(data_path, 'FeatureList.mat');

if strcmp(status, 'init')
	semaphore('create', key, 1);
	semaphore('wait', key);
	FeatureList{1} = zeros(1,max(param1)) - 1;
	for i = 1:length(param1)
		idx = param1(i);
		FeatureList{1}(idx) = 0;
		FeatureList{2}{idx} = clock;	
	end	
	save(FeatureList_path, 'FeatureList');
	semaphore('post', key);
end

if strcmp(status, 'fetch')
	
	semaphore('wait', key);
	FeatureList = importdata(FeatureList_path);
	for i = 1:length(FeatureList{1})
		if FeatureList{1}(i) == 0
			res = i;
			FeatureList{1}(i) = 1;
			FeatureList{2}{i} = clock;
			save(FeatureList_path, 'FeatureList');
			break;
		end
	end 
	semaphore('post', key);
end

if strcmp(status, 'finish')
	
	semaphore('wait', key);
	FeatureList = importdata(FeatureList_path);
	FeatureList{1}(param1) = -1;
	save(FeatureList_path, 'FeatureList');
	semaphore('post', key);
end

if strcmp(status, 'update')
	semaphore('wait', key);
	FeatureList = importdata(FeatureList_path);
	% push for zombie to end
	for i = 1:length(FeatureList{1})
		if FeatureList{1}(i) > 0
			et = etime(clock, FeatureList{2}{i});
			if et > thres 
				% a zombie feature
			 	if( readParam('debug_on') )	
					disp(['FeatureManager: clean zombie feature ', num2str(i)]);
				end
				FeatureList{1}(i) = 0;
				FeatureList{2}{i} = clock;
				jm_path = strcat(data_path, readParam('job_filename',1), '_', int2str(i), '.mat');	
				if exist(jm_path) ~= 0
				 	delete(jm_path);	
				end
			end
		end
	end
	save(FeatureList_path, 'FeatureList');
	semaphore('post', key);

end


if strcmp(status, 'is_finish')
	
	semaphore('wait', key);
	res = 1;
	FeatureList = importdata(FeatureList_path);
	for i = 1:length(FeatureList{1})
		if FeatureList{1}(i) ~= -1 
			res = 0;
			break;
		end
	end 
	semaphore('post', key);
end



end
