addpath('../../../parallel_measure')
addpath('../../../ToolBox/util/')
addpath('../../../ToolBox/')


parallel_handler(8);


% buflo
% exp_tag = {'buflo_5', 'buflo_10', 'buflo_20', 'buflo_30', 'buflo_40', 'buflo_50', 'buflo_60',  'buflo_80', 'buflo_100', 'buflo_120'};



% tamaraw
%exp_tag = {};
%count = 1;
%
%for i = [10:10:90, 100:100:1000]
%  tag_no = strcat('tamaraw_no_obfuscate_', num2str(i));
%%  tag_with = strcat('tamaraw_with_obfuscate_', num2str(i));
%  exp_tag{count} = tag_no;
%%  exp_tag{count+1} = tag_with;
%  count = count + 1;
%end



% WTF

%exp_tag = {'top500'};
%count = 1;
%
%for i = 6:9
%  wtf = strcat('WTF_0.', num2str(i));
%  exp_tag{count} = wtf;
%  count = count + 1;
%end



% cs_buflo

%exp_tag = {'cs_buflo'};


% WTF_NORMAL
%exp_tag = {'WTF_NORMAL'};



% bootstrap websites

%for i = 1:20
%exp_tag{i} = num2str(i-1);
%end


% top100 closed world
exp_tag = {'top100'};


% only top100
idata = importdata('/home/shuai/projects/TrafficAnalysis/experiment/exp3.0/no_defense/info/top100/combine_measure/MIanalysis/MIanalysis_cat1_topn100.mat');
topFlist = idata.topnFeatureList;


for i = 1:length(exp_tag)
  % each experiment
  tag = exp_tag{i}
  for idx = topFlist 
%  for idx = 1:1 
    parfor bs = 0:20
      solo_individual(tag, idx, bs);
    end
  end
end


%% supersequence
%exp_tag = {};
%count = 1;
%
%for cluster = [2:2:10, 20, 35, 50]
%  exp_tag{count} = strcat('supersequence_method4supercluster2_clusternum', num2str(cluster), '_stoppoints4');
%  count = count + 1;
%end
%
%for supercluster = [2,5,10]
%  for stop = [4,8,12]
%    exp_tag{count} = strcat('supersequence_method3supercluster', num2str(supercluster), '_clusternum20_stoppoints', num2str(stop));
%    count = count + 1;
%  end	
%end
%
%bootstrap_num = 50;
%
%
%for i = 1:length(exp_tag)
%  % each experiment
%  tag = exp_tag{i}
%  idx = [2,3];
%  parfor bstrap = 0:bootstrap_num 
%    solo_individual(tag, idx, bstrap);
%  end
%end
