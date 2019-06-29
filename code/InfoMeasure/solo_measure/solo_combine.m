%function results = solo(tag)
function info = solo_combine(exp_tag, category_idx, topn, bstrap_idx)

RESULT_PATH = strcat('./debug_data/', exp_tag, '_category', num2str(category_idx), '_topn', num2str(topn), '_bstrap', num2str(bstrap_idx), '.mat');

home_directory = readParam('home_directory', 1)
%MIanalysis_path = strcat(home_directory, 'experiment/exp3.0/no_defense/info/', exp_tag, '/combine_measure/MIanalysis/MIanalysis_cat', num2str(category_idx), '_topn', num2str(topn), '.mat');
%MIanalysis_path = strcat(home_directory, 'experiment/exp3.0/accuracy_info/info/', exp_tag, '/combine_measure/MIanalysis/MIanalysis_cat', num2str(category_idx), '_topn', num2str(topn), '.mat');
MIanalysis_path = strcat(home_directory, 'experiment/exp3.0/no_defense/info/', 'top100', '/combine_measure/MIanalysis/MIanalysis_cat', num2str(category_idx), '_topn', num2str(topn), '.mat');
m = importdata(MIanalysis_path);


vec =m.vec;


Dataset_path = strcat('/export/scratch2/shuai/TrafficAnalysis/Dataset/DataMatrix/');
%Dataset_path = strcat('/export/scratch2/shuai/TrafficAnalysis/attack/KNN/Dataset/DataMatrix/');
%Dataset_path = strcat('/export/scratch2/shuai/TrafficAnalysis/Dataset/DataMatrix/bootstrap/');
%Dataset_path = strcat('/home/shuai/projects/TrafficAnalysis/Dataset/DataMatrix/');
monitor_dataset = strcat(Dataset_path, exp_tag, '/');
argMap = containers.Map();
argMap('monitor_dataset') = monitor_dataset;

% build the model
if bstrap_idx == 0
    % no bootstrap
    info = model_init(vec, 0, 0, argMap);
else
    info = model_init(vec, 1, 0, argMap);
end



webNum = length(info.WebsiteList);


parfor i = 1:webNum
  temp = info.Evaluate(i, []);
  res{i} = temp{i};
end


results.JobResults = res;

save(RESULT_PATH, 'results');


end
