% main.m:       generate MIanalysis structure
function is_success = exp_mianalysis(exp_tag)

diary on;

% packages should be added
addpath('../InfoMeasure/ToolBox/');
addpath('../InfoMeasure/ToolBox/util/');


% need specify

% defense 
dataset_path = strcat('../KNN/Dataset/DataMatrix/', exp_tag, '/');
experiment_path = strcat('../../experiment/exp3.0/accuracy_info/info/', exp_tag, '/');


% no_defense 
%dataset_path = strcat('../../Dataset/DataMatrix/', exp_tag, '/');
%experiment_path = strcat('../../experiment/exp3.0/no_defense/info/', exp_tag, '/');



% hard coded
MIanalysis_path = strcat(experiment_path, 'combine_measure/MIanalysis/MIanalysis_');
ent_path = strcat(experiment_path, 'individual_measure/results/ave_entropy.mat');


selector = GetSelector();

ent = importdata(ent_path);

% construct MIanalysis structure
m = MIanalysis(dataset_path, ent);

for i = 1:length(selector)
    disp(['selector[', num2str(i), ']']);
    % get parameters
    feature_list = selector{i}{1};
    topn_list = sort( selector{i}{2}, 'descend' );
    
 
    
    for topn = topn_list
		t1 = clock;
		m.setup(feature_list, topn);
		vec = m.groupByMI();
		
		% save vec and topnFeatureList
		path = strcat(MIanalysis_path, 'cat', num2str(i), '_topn', num2str(topn), '.mat');
		topnFeatureList = m.topnFeatureList;
		save(path, 'vec', 'topnFeatureList');
		
		t2 = clock;
		disp(['topn = ', num2str(topn), ', with ', num2str(etime(t2,t1)), ' seconds']);
    end
end


% save mi of the highMIpruner
path = strcat(MIanalysis_path, 'mi.mat');
mi = m.MIprun.mi;
save(path, 'mi');


diary off;
end
