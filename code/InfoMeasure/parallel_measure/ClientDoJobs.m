function result = ClientDoJobs(info, jobs)
c = gcp('nocreate');
if isempty(c)
  parallel_handler(2);
end


% job_num copies of info
job_num = length(jobs)/2;

result = zeros(1, job_num); 

%info_list = cell(1, job_num);
%for i = 1:job_num
%    info_list{i} = info;
%end

% do the jobs in parallel
parfor i = 1:job_num
    web_index = jobs(2*i-1)
    sample_index = jobs(2*i)
%    temp = info_list{i}.Evaluate(web_index, sample_index)
    temp = info.Evaluate(web_index, sample_index)
    result(i) = temp{web_index}(sample_index);
end


end
