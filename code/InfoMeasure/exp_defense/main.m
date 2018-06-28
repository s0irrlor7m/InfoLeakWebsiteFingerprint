% main


addpath('../parallel_measure/');
addpath('../ToolBox/');
addpath('../ToolBox/util/');
addpath('../ToolBox/GetMD5/')
addpath('../ToolBox/semaphore/')
addpath('../../MIanalysis/');


parallel_handler;


%exp = experiment_individual();
exp = experiment_combine();
%exp = experiment_openworld();
exp.execute();
