function info = model_init(vec, bootstrap, is_openworld, argMap)
%%%%% vec: which feature(s) to consider
%%%%% experiment_tag: the tag to denote the experiment (used for storing results)

%addpath('../ToolBox');


% argMap: A way to overide the Param.txt

if nargin < 4
	argMap = containers.Map();
end


%%%%%%%%%%%%%  setup parameters for open world experiment  %%%%%%%%%%%%%


% how many samples in total
if argMap.isKey('mcarlo_num')
	mcarlo_num = argMap('mcarlo_num');
else
	mcarlo_num = readParam('mcarlo_num');
end

% discreteThres
if argMap.isKey('discrete_thres')
    discreteThres = argMap('discrete_thres');
else
    discreteThres = readParam('discrete_thres');
end


% prior type
if argMap.isKey('prior_type')
	prior_type = argMap('prior_type');
else
	prior_type = readParam('prior_type', 1);
end

% dataset path
if argMap.isKey('monitor_dataset')
	monitor_dataset = argMap('monitor_dataset');
else
	monitor_dataset = readParam('monitor_dataset', 1);
end

if argMap.isKey('non_monitor_dataset')
	non_monitor_dataset = argMap('non_monitor_dataset');
else
	non_monitor_dataset = readParam('non_monitor_dataset', 1);
end


% bootstrap options, if required
if argMap.isKey('reModel_krate')
	reModel_krate = argMap('reModel_krate');
else
	reModel_krate = readParam('reModel_krate');
end

% selector:     bootstrap 1; subsampling 2
if argMap.isKey('selector')
	selector = argMap('selector');
else
	selector = readParam('selector');
end

    
%%%%%%%%% import data and build the models %%%%%%%%%%%%%%%%%%

reader_monitor = TrainMatrixReader(monitor_dataset, discreteThres);

Tmatrix{1} = reader_monitor.TrainMatrix;
label{1} = reader_monitor.Label;
DiscVec{1} = reader_monitor.isDiscVec;

% difference between closed and openworld:
% the latter has Tmatrix{2} and label{2}
% that's how EvaluatorMachine distinguashes these two 

if is_openworld == 1
    reader_non_monitor = TrainMatrixReader(non_monitor_dataset, discreteThres);
    Tmatrix{2} = reader_non_monitor.TrainMatrix;
    label{2} = reader_non_monitor.Label;
    DiscVec{2} = reader_non_monitor.isDiscVec;
end

if is_openworld == 1
    prior = PriorWebsites(prior_type, reader_monitor.Rank, reader_non_monitor.Rank);
else
    prior = PriorWebsites(prior_type, reader_monitor.Rank);
end

% save priors
mname = char(java.net.InetAddress.getLocalHost.getHostName);
if argMap.isKey('prior_filename')
	prior_path = strcat(readParam('debug_data',1),'/', mname, '/', argMap('prior_filename'));
else
	prior_path = strcat(readParam('debug_data',1),'/', mname, '/', 'prior.mat');
end


info = EvaluatorMachine(Tmatrix, label, vec, prior, DiscVec);

if bootstrap == 1
    info.reModel(reModel_krate, selector);
end


if exist(prior_path) == 0
    mflag = info.MonitorFlag;
    save(prior_path, 'prior', 'mflag');
end


%%%%%%%%%% generate samples and save %%%%%%%%%%%%%%%%%%%%%
info.GenerateSamples(mcarlo_num);


end
