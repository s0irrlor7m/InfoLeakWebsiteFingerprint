function is_success = server(info, ftag, port_number)

% the server would timeout  


is_success = 0;




if nargin > 2
    port_num = port_number;
else
    port_num = readParam('port_number');
end



st_time = clock;

% prepare info

% addpath('../ToolBox/GetMD5');
% addpath('../ToolBox/');
% addpath('../ToolBox/util/')


% setup the folder to contain the data
mname = char(java.net.InetAddress.getLocalHost.getHostName);
data_path = strcat(readParam('debug_data',1),'/', mname, '/');

info_path = strcat(data_path, int2str(port_num), '_', readParam('info_filename',1));
jm_path = strcat(data_path, readParam('job_filename',1), '_', ftag, '.mat');

if exist(data_path) == 0
    mkdir( data_path );
end



if exist(info_path) ~= 0
    delete(info_path);
end
save('-v7.3', info_path, 'info');


disp('before assert');


% check existence of info

assert(exist(info_path) ~= 0);

% import the model as bytes
disp('after assert');

%fd = fopen(info_path);
%info_binary = fread(fd);
%fclose(fd);


% split the job
jm = JobManager(info, readParam('job_size'), readParam('job_refresh_threshold'));
% clear info
clear info;




% StateMachine
smachine = StateMachine();
info_hash = GetMD5(info_path, 'File', 'double');



now_epoch = 0;

disp('ready to connect!');

while 1
    try
        % wait for new connection
        [t, is_suc] = NonBlockAccept(port_num);
	if is_suc == 0
		if readParam('debug_on')	
			disp(['server error: ', num2str(port_num)]);
		end
		continue; %break;
	end
    
    
        % whether a new remote host
        is_exist = smachine.IsExist(t.remoteHost);
        if is_exist == 0
            % new remotehost
            smachine.AddWorker(t.remoteHost);
        end
        
        %%%%%%%% behave based on state code
        state = smachine.ip2state(t.remoteHost);
        
        % make client stateless 
	
	% is_reset, read from client
	if bulk_read(t)
		% reset its state to 0	
		smachine.UpdateState(t.remoteHost, 0);
	end
        
        %%%%%%%% behave based on state code
        state = smachine.ip2state(t.remoteHost);
        bulk_write(t, state);
            
        if state == 0
            % new remote host, send info.mat
            % transmit to state 1
            if readParam('debug_on')
                disp(strcat(t.remoteHost, ': info model requested'));
                c=clock;disp( c(4:6) );
            end
%            bulkplus_write(t, info_binary);
            smachine.UpdateState(t.remoteHost, 1);
             
        elseif state == 1
            % check the correctness of info.mat
            h = bulk_read(t);
            if sum(h' == info_hash) == length(info_hash)
                bulk_write(t, 1);
                smachine.UpdateState(t.remoteHost, 2);
                if readParam('debug_on')
                    disp(strcat(t.remoteHost, ' passed the info check'));
                end    
            else
                bulk_write(t, 0);
                smachine.UpdateState(t.remoteHost, 0);
                if readParam('debug_on')
                    disp(strcat(t.remoteHost, ' failed the info check'));
                end
            end
        elseif state == 2
            % it's time to distribute the jobs
            jobs = jm.GetJobs('hostname');
            if length(jobs) ~= 0
                % has jobs to assign
                smachine.RecordJobs(t.remoteHost, jobs);
                bulk_write(t, jobs);
                smachine.UpdateState(t.remoteHost, 3);
                if readParam('debug_on')
                    disp(strcat(t.remoteHost, ': assigned jobs to it'));
                end
            else
                % no jobs to assign
                bulk_write(t, 0);
                smachine.UpdateState(t.remoteHost, 5);
            end
            
        elseif state == 3
            % to receive the results
            results = bulk_read(t)';
            smachine.RecordResults(t.remoteHost, results);
            smachine.UpdateState(t.remoteHost, 4);
            if readParam('debug_on')
                disp(strcat(t.remoteHost, ': received job results'));
            end
        elseif state == 4
            % to check and validate the results
            h = bulk_read(t)';
            jobs = smachine.GetJobs(t.remoteHost);
            results = smachine.GetResults(t.remoteHost);
            h_local = GetMD5([jobs, results], 'Array', 'double');
            
            if sum(h_local == h) == length(h)
                jm.RecordJobResults(jobs, results);
                save(jm_path, 'jm');
                if readParam('debug_on')
                    disp(strcat(t.remoteHost, ': validated job results with storage'));
                end
            else
                jm.ResetJobs(jobs);
                if readParam('debug_on')
                    disp(strcat(t.remoteHost, ': failed job results with drop'));
                end
            end
            smachine.UpdateState(t.remoteHost, 2);
        elseif state == 5
            % idle state, only check for availability of jobs
            if jm.IsFinished() == 0 
                jm.RefreshJobList();
                smachine.UpdateState(t.remoteHost, 2);
            end
        else
    
        end
	
	% close the socket
	jtcp('close', t)

% 	abandom elapsed time for refresh job list	
%        % refresh JobList if new epoch reached
%        cur_time = clock;
%        elap = etime(cur_time, st_time);
%        
%        cur_epoch = floor( elap/readParam('epoch_time') );
%        if(cur_epoch > now_epoch)
%            now_epoch = cur_epoch;
%            jm.RefreshJobList();
%        end

        % is all job finished
        if(jm.IsFinished())
	    is_success = 1;	
            break;
        end
    catch ME
        if readParam('debug_on_plenty')
            disp(ME.identifier);
    	    save('error.mat', 'ME');
        end
        continue;
        
    end
end


end
