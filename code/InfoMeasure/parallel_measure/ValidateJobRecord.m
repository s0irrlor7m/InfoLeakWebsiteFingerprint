function isvalid = ValidateJobRecord(path)


isvalid = 1;

if exist(path) == 0
    % no record found!
    isvalid = 0;
else
    % a record exist
    JobRecord = importdata(path);
    for j = length(JobRecord.JobList)
        if sum(JobRecord.JobList{j} == -1) ~= length(JobRecord.JobList{j})
            % exist non -1 element
            isvalid = 0;
        end
    end

end








end