
addpath('../InfoMeasure/parallel_measure/');

% handle cuncurrent processing in networked machines
parallel_handler(32); 




% BUFLO
%exp_mianalysis('buflo_5');
%exp_mianalysis('buflo_10');
%exp_mianalysis('buflo_20');
%exp_mianalysis('buflo_30');
%exp_mianalysis('buflo_40');
%exp_mianalysis('buflo_50');
%exp_mianalysis('buflo_60');
%exp_mianalysis('buflo_80');
%exp_mianalysis('buflo_100');
%exp_mianalysis('buflo_120');

% glove
%exp_mianalysis('glove');


% TAMARAW
%exp_mianalysis('tamaraw_no_obfuscate');
%exp_mianalysis('tamaraw_with_obfuscate');


%% WTF
%exp_mianalysis('WTF_0.1');
%exp_mianalysis('WTF_0.2');
%exp_mianalysis('WTF_0.3');
%exp_mianalysis('WTF_0.4');
%exp_mianalysis('WTF_0.5');
%exp_mianalysis('WTF_0.6');
%exp_mianalysis('WTF_0.7');
%exp_mianalysis('WTF_0.8');
%exp_mianalysis('WTF_0.9');


%% top100
%exp_mianalysis('top100');


%% cs_buflo
exp_mianalysis('cs_buflo');
