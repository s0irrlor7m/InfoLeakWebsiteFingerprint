function [t, is_success] = NonBlockAccept(port_num)
t = 0;
    
while 1
    try
        t = jtcp('accept', port_num, 'timeout', readParam('server_timeout'));
	is_success = 1;
        break;
    catch ME
%        if readParam('debug_on_plenty')
%            disp(ME.identifier);
%	    save('NonBlockError.mat', 'ME');	
%        end
%	% if timeout, break
%	temp = ME.ExceptionObject;
%	temp = whos('temp');
%	
%	if strcmp(temp.class, 'java.net.SocketTimeoutException')
%		is_success = 0;
%		break;
%	end
    	pause(0.5);
    end

end



end
