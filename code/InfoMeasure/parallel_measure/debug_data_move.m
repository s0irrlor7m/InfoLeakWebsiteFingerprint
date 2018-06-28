% experiment 1
addpath('../ToolBox/util/');

DEST = '../../../experiment/exp2.0/e1/';

idx = 1:3043;

mname = char(java.net.InetAddress.getLocalHost.getHostName);
data_path = strcat(readParam('debug_data',1),'/', mname, '/');




for i = idx
    filename = strcat(readParam('job_filename',1), '_', int2str(i), '.mat')
	jm = strcat(data_path, filename);
    jm_temp = importdata(jm);
    CondEnt = jm_temp.JobResults;
    de = strcat(DEST, filename);
    save(de, 'CondEnt');
    clear jm_temp CondEnt de jm filename;
end



