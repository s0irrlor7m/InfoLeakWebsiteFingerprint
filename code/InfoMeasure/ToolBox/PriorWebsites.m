function  pr = PriorWebsites(method, rank_m, rank_nm)
% closed world: ignore rank_nm (set to 0 in use)
% open world:   rank_m for monitored, rank_nm for non-monitored    


% only for Open_World_Zipf+
prm = 0.3;

% assume equal probability for monitored (closed world)
if strcmp(method, 'Closed_World_Equal')
    pr = zeros(1, length(rank_m)) + 1/length(rank_m);
end

% assume zipf probability for monitored (closed world)
if strcmp(method, 'Closed_World_Zipf') 
    pr = zipf(rank_m);
end

% assume zipf probability for monitored and non-monitored (open world)
if strcmp(method, 'Open_World_Zipf') 
    pr = zipf([rank_m; rank_nm]);
end

if strcmp(method, 'Open_World_Zipf+') 
    monitor_pr = zipf(rank_m) * prm;
    non_monitor_pr = zipf(rank_nm) * (1-prm);
    pr = [monitor_pr, non_monitor_pr];
end


end
