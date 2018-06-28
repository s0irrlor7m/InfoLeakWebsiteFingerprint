function prob = zipf(rank)

% rank: array containing rank info
% return: the probability for each rank (summation = 1)


indiv = [];

for i = 1:length(rank)
    if rank(i) ~= 0
    	indiv = [indiv, rank(i)^(-1)];
    else
        indiv = [indiv, 0];	
    end
end

prob = indiv./sum(indiv);




end
