function is_success = superServer(info, ftag, port_number)


if nargin > 2
    port_num = port_number;
else
    port_num = readParam('port_number');
end



% distributor number
dnum = readParam('server_number');




%%%% deal with info 
mname = char(java.net.InetAddress.getLocalHost.getHostName);
data_path = strcat(readParam('debug_data',1),'/', mname, '/');

info_path = strcat(data_path, int2str(port_num), '_', readParam('info_filename',1));

if exist(info_path) ~= 0
    delete(info_path);
end
save('-v7.3', info_path, 'info');



%%%  spawn distributor 
proc = {};
runtime = java.lang.Runtime.getRuntime();
for i = 1:dnum
    command = strcat('matlab -nodisplay -r addpath(''../parallel_measure/'');addpath(''../ToolBox/util/'');infoDistributor(', num2str(port_num), ',', num2str(i), ')')
    proc{i} = runtime.exec(command);
end



%%%%%%%%%%%%% run server %%%%%%
is_success  = server(info, ftag, port_num);


%%% end the child processes
for i = 1:dnum
%    proc{i}.waitFor();
    proc{i}.destroy();
end

end
