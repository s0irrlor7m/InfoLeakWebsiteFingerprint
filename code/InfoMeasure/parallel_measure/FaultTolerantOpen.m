function t = FaultTolerantOpen(server_ip, port_num, port_max)
if nargin < 3
    port_max = port_num;	
end 

while 1
    try
        % random a port between port_num and port_max
        cur_port = randi([port_num, port_max]);

        t = jtcp('request',server_ip, cur_port, 'timeout', 6000);
        break;
    catch ME 
      if readParam('debug_on_plenty') 
        disp(ME.identifier); 
      end
      fclose all;
        switch ME.identifier 
            case 'jtcp:connectionRequestFailed'
                pause(2);
            otherwise
                disp(ME.identifier);
                pause(2); 
        end

    end


end
