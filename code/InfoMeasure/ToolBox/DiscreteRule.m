function dv = DiscreteRule(web_data, thres, data_path)
%%% decide whether a instance belongs to discrete or continuous mode
%%% 1st param:  instances (by rows) of a website
%%% 2nd param:  where the dataset is (for exact recognision)


if thres >= 0
    method = 0;
else
    method = 1;
end

% use a threshold to decide
if method == 0
    dv = byThres(web_data, thres);
end

% use exact match to decide (if know which one is discrete)
if method == 1
    dv = byPattern(web_data, data_path);
end



end


function isDiscVec = byPattern(web_data, data_path)

% import pattern
pattern_path = strcat(data_path, 'patterns.txt');
patterns = importdata(pattern_path);


% initiate isDiscVec and decide..
[sampleNum, featureNum] = size(web_data);
isDiscVec = NaN(sampleNum, 1);


for i = 1:sampleNum
    samplei = web_data(i,:);
    if patternMatch(samplei, patterns)
        % find a match: discrete
        isDiscVec(i) = 1;
    else
        isDiscVec(i) = 0;
    end
end


end


% search for equality of samplei in patterns
function isMatch = patternMatch(samplei, patterns)

np = size(patterns,1);

isMatch = 0;
for i = 1:np
    pattern = patterns(i,:);
    if isEqualSample(samplei, pattern)
        % find a match
        isMatch = 1;
        break;
    end
end


end

function res = isEqualSample(sample1, sample2)
% return true is two samples are equal
dim = length(sample1);
if sum(sample1 == sample2) == dim
    res = 1;
else
    res = 0;
end

end

function isDiscVec = byThres(web_data, DiscreteThres)
% recognize which data point is discrete or not
% based on obj.raw_data
[sampleNum, featureNum] = size(web_data);
isDiscVec = NaN(sampleNum, 1);

for i = 1:sampleNum
    % if i has been processed
    if ~isnan( isDiscVec(i) )
        continue;
    end
    
    equal_list = [i];
    samplei = web_data(i,:);
    
    % find following equal samples...
    for j = (i+1):sampleNum
        samplej = web_data(j,:);
        if isEqualSample(samplei, samplej)
            % if samplei == samplej
            equal_list = [equal_list, j];
        end
    end
    
    % determine to be discrete or continuous
    if length(equal_list) >= DiscreteThres
        % bigger than threshold: discrete
        isDiscVec(equal_list) = 1;
    else
        % smaller than threshold: continuous
        isDiscVec(equal_list) = 0;
    end
    
end


end




