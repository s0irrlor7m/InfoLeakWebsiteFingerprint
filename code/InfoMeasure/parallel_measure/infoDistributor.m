function infoDistributor(port_number, count)


% setup the folder to contain the data
mname = char(java.net.InetAddress.getLocalHost.getHostName);
data_path = strcat(readParam('debug_data',1),'/', mname, '/');
info_path = strcat(data_path, int2str(port_number), '_', readParam('info_filename',1));





while 1
    try
        % wait for new connection
        [t, is_suc] = NonBlockAccept(port_number+count);
        if is_suc == 0
            disp(['server timeout: ', num2str(port_number+count)]);
            continue;%break;
        end
        
        % transmit info

        % import the model as bytes
	      t1 = clock;
        if exist(info_path) ~= 0
            
            % decide whether to read from file
            isRead = 0;
            if exist('info_binary') == 0
              % first time to read
              isRead = 1;
            else
              % more than first time, check hash
              new_hash = GetMD5(info_path, 'File', 'double');
              if ~isequal(new_hash, info_hash)
                isRead = 1;
              end
            end

            % read if necessary
            if isRead == 1
              clear info_binary info_hash;
              fd = fopen(info_path);
              info_binary = fread(fd);
              fclose(fd);
              info_hash = GetMD5(info_path, 'File', 'double'); 
            end
        else
            % info not exist
            jtcp('close', t);
            continue;
        end

        disp(strcat(t.remoteHost, ': connectted to'));
        bulkplus_write(t, info_binary);
        t2 = clock;
        disp(strcat(t.remoteHost, ': info model transmitted in ', num2str(etime(t2,t1))));
        jtcp('close', t);
    catch ME
        disp(ME.identifier);
        continue;
    end
       
end

end
