function final = bulk_read(t)
% the socket read will not block, spinning...though


countdown = readParam('read_timeout');


while 1
    rcv = jtcp('read', t);
    var_info = whos('rcv');
    if var_info.bytes ~= 0
        break;
    end
    
    % count down
    countdown = countdown - 1000;
    if countdown < 0
       error('bulk_read timeout!');
    end 
    pause(1);
end

final = rcv;


end
