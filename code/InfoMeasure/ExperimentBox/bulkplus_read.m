function final = bulkplus_read(t)
% the socket read will not block, spinning...though

final = [];

isReceive = 0;
countdown = readParam('read_timeout');
while 1
    rcv = jtcp('read', t);
    var_info = whos('rcv');
    if var_info.bytes ~= 0
      isReceive = 1;
	    if var_info.size(1) <= readParam('partition') 
		    % a normal block
		    final = [final; rcv];
 	    else
		    % a ending block
		    break;		 
	    end	
    end

    % timeout, if isReceive false
    if isReceive == 0
      countdown = countdown - 1000;
      if countdown < 0
        error('bulkplus_read timeout!');
      end
      pause(1);
    end
end


end
