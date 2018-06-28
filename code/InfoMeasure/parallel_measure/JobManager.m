classdef JobManager < handle
    properties
        % JobList: record job status. not assigned(0), positive(in process), -1(finished) 
        JobList
        JobSize
        
        JobResults
        thres
    end
    
    methods
        function obj = JobManager(info, jobsize, thres)
            web_num = length(info.WebsiteList);
            obj.JobList = cell(1, web_num);
            obj.JobResults = cell(1, web_num);
            
            for i = 1:web_num
                obj.JobList{i} = zeros(1,size(info.SampleList{i}, 1));
                obj.JobResults{i} = zeros(1,size(info.SampleList{i}, 1));

            end
            
            obj.JobSize = jobsize;
            obj.thres = thres;
        end
        
        function jobs = GetJobs(obj, hostname)
            jobs = [];
            flag = 0;
            web_num = length(obj.JobList);
            for each_web = 1:web_num
                
                sample_num = length(obj.JobList{each_web});
                for each_sample = 1:sample_num
                    
                    if obj.JobList{each_web}(each_sample) == 0
                        jobs = [jobs, each_web, each_sample];
                        obj.JobList{each_web}(each_sample) = 1;
                        if length(jobs) == 2*obj.JobSize
                            flag = 1;
                            break;
                        end
                    end
                end
                
                if flag == 1
                    break;
                end
            end
        end
        
        function ResetJobs(obj, jobs)
            job_num = length(jobs)/2;
            for i = 1:job_num
                web_index = jobs(i*2 - 1);
                sample_index = jobs(i*2);
                obj.JobList{web_index}(sample_index) = 0;
            end
        end
        
        
        function RecordJobResults(obj, jobs, results)
            job_num = length(jobs)/2;
            for i = 1:job_num
                web_index = jobs(i*2 - 1);
                sample_index = jobs(i*2);
                obj.JobList{web_index}(sample_index) = -1;
                obj.JobResults{web_index}(sample_index) = results(i);
            end
            
        end
        
        % check if there is jobs to assign
        function res = IsAvailJob(obj)
            res = 0;
            
            web_num = length(obj.JobList);
            for i = 1:web_num
                sample_num = length(obj.JobList{i});
                for j = 1:sample_num
                    if obj.JobList{i}(j) == 0
                        res = 1;
                        break;
                    end
                end
                
                if res == 1
                    break;
                end
                
            end
            
        end
        
        % check if finished
        function res = IsFinished(obj)
            res = 1;
            
            web_num = length(obj.JobList);
            for i = 1:web_num
                sample_num = length(obj.JobList{i});
                for j = 1:sample_num
                    if obj.JobList{i}(j) ~= -1
                        res = 0;
                        break;
                    end
                end
                
                if res == 0
                    break;
                end
                
            end
            
        end
        
        
        function RefreshJobList(obj)
            % reset the jobs
            web_num = length(obj.JobList);
            
            for i = 1:web_num
                sample_num = length(obj.JobList{i});
                for j = 1:sample_num
                    if obj.JobList{i}(j) > 0
                        obj.JobList{i}(j) = obj.JobList{i}(j) + 1;
                        
                        if obj.JobList{i}(j) > obj.thres
                            obj.JobList{i}(j) = 0;
                        end
                    end
                end
            end
        
        end
        
    end
end