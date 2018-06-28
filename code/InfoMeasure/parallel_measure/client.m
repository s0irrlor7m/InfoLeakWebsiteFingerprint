% data = sin(1:64);
% plot(data);
clear;
%parallel_handler;

addpath('../ToolBox/GetMD5');
addpath('../ToolBox/');
addpath('../ToolBox/util/');







% setup the folder to contain the data
mname = char(java.net.InetAddress.getLocalHost.getHostName);
data_path = strcat(readParam('debug_data',1),'/', mname, '/');
info_path = strcat(data_path, readParam('info_filename',1));

if exist(data_path) == 0
    mkdir( data_path );
end

% select a server to work on machine number % server_num
%which_server = rem( str2num(mname(13:14)), readParam('server_number') ) + 2;


port_number = readParam('port_number');



%%%

%diary( strcat(data_path, 'mydata.out') );
% init socket...

IsDoJob = 0;
is_reset = 0;

while 1  
    fclose all;
    if IsDoJob == 1
        % do the jobs, then connect
        if readParam('debug_on')
            tic
        end
        result = ClientDoJobs(info, jobs);
        if readParam('debug_on')
            toc
        end
        IsDoJob = 0;
    end

	% to keep client alive
	try
        % reach central control server
	    t = FaultTolerantOpen(readParam('server_address',1), port_number+1);
	    % if to reset...
	    bulk_write(t, is_reset);	 
	    is_reset = 0;
	    % read state from the server
	    state = bulk_read(t);
	
	    if state == 0
            jtcp('close', t);
            
            % go to distributor to get info
            while 1
                try
                    g = FaultTolerantOpen(readParam('server_address',1), port_number+2, port_number + 1 + readParam('server_number'));
                    disp(strcat('ask port ', num2str(g.port), 'for info...'));
                    info_binary = bulkplus_read(g);
                    jtcp('close', g);    
                    break;
                catch ME
                    disp(ME.identifier);
                    jtcp('close', g);
                    continue;
                end
            end
            % save info
	        fd = fopen(info_path, 'w');
	        fwrite(fd, info_binary);
	        fclose(fd);
          clear info_binary;
	        
	    elseif state == 1
	        disp('Create Hash of the info model for checking...');
	        h = GetMD5(info_path, 'File', 'double');
	        disp(strcat('the hash: ', h));
	        
	        bulk_write(t, h);
	        res = bulk_read(t);
	        if res == 1
	            state = 2;
	            info = importdata(info_path);
	            disp('Checking passed for the info model');
	        else 
	            state = 0;
	            disp('Checking failed to return to 0 state');
	        end
	        jtcp('close', t);
	    elseif state == 2
	        jobs = bulk_read(t)';
	        jtcp('close', t);
	        % is job empty? 
	        if length(jobs) > 1
	          IsDoJob = 1;
	        end
	
	        
	    elseif state == 3
	        bulk_write(t, result);
	        jtcp('close', t);
	
	    elseif state == 4
	        % check the md5
	        h = GetMD5([jobs, result], 'Array', 'double');
	        bulk_write(t, h);
	        jtcp('close', t)
	    elseif state == 5 
	        pause(10);
          jtcp('close', t);
	    end
	catch ME
		disp(ME.identifier);
    save('ME.mat', 'ME');
		is_reset = 1;	
		continue;
	end
end
%diary off;
