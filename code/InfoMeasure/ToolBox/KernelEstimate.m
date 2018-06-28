function output = KernelEstimate(FeatureSample)
% FeatureSample:            an n*1 matrix with rows to be instances


bandwidth1 = 0.9 * min( std(FeatureSample), iqr(FeatureSample)/1.34 ) * length(FeatureSample)^(-0.2);

%%% debug
bandwidth1 = bandwidth1/10;

%%% end


if bandwidth1 ~= 0
    pdf = fitdist(FeatureSample,'Kernel','BandWidth',bandwidth1, 'Kernel', 'normal');
else
    pdf = fitdist(FeatureSample,'Kernel','BandWidth', 1, 'Kernel', 'normal');
end
    
output = pdf;    
end
