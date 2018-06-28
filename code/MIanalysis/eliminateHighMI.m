function highMI = eliminateHighMI(mi, thres)
cand_num = size(mi,1);
highMI = [];
for i = 1:cand_num
    if sum( highMI == i ) > 0
        continue;
    end
    
    for j = (i+1):cand_num
        if mi(i, j) > thres && sum( highMI==j ) == 0
            highMI = [highMI, j];
        end
    end
end

end