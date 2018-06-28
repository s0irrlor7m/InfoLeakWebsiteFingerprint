function bulk_write(t, data)
% the data exceeds the java heap size
partition = readParam('partition');

for i = 1:ceil(length(data)/partition)
	st = 1 + (i-1)*partition;
	ed = i*partition;
	if ed > length(data)
		ed = length(data);
	end
	jtcp('write', t, data(st:ed) );
	t.outputStream.reset;
end


% denote the end
jtcp('write', t, zeros(1,partition+1));

end
