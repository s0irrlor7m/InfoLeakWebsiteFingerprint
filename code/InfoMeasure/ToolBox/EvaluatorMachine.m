classdef EvaluatorMachine < handle
    
    properties
        WebsiteList
        MonitorFlag
        prior
        
        model_vector
        original_vector
        isDiscVec

        
        SampleList
        SampleNum
        
        feature_num
        IsOpenWorld
        
    end
    
    methods
        % TrainMatrix and Label be cell
        function obj = EvaluatorMachine(TrainMatrix, Label, vec, websites_prior, DiscVec)

            obj.isDiscVec = DiscVec;
            obj.original_vector = vec;
            % optimize: only keep the features that matter
            TrainMatrix{1} = TrainMatrix{1}(:,vec>0);
            if length(TrainMatrix) == 2
                TrainMatrix{2} = TrainMatrix{2}(:,vec>0);
            end
            new_vec = vec(vec>0);
            
            
            
            %display('Construct EvaluatorMachine');
            obj.model_vector = new_vec;
            obj.feature_num = size(TrainMatrix{1},2);
            obj.prior = websites_prior;
            % no matter closed/open, at least have cell 1 for TrainMatrix
            % and Label
            for l = min(Label{1}):max(Label{1})
                id = l;
                %id
                web_data = TrainMatrix{1}(Label{1}==l,:);
                dv = obj.isDiscVec{1}(Label{1}==l);
                obj.WebsiteList{id} = Websiter(id, obj.model_vector, web_data, dv);
                obj.MonitorFlag(id) = 1;
                obj.WebsiteList{id}.BuildPDF();
            end
            
            % if open world
            if length(Label) == 2
                obj.IsOpenWorld = 1;
                id_close = id;
                for l = min(Label{2}):max(Label{2})
                    id = id_close + l;
                    web_data = TrainMatrix{2}(Label{2}==l,:);
                    dv = obj.isDiscVec{2}(Label{2}==l);
                    obj.WebsiteList{id} = Websiter(id, obj.model_vector, web_data, dv);
                    obj.MonitorFlag(id) = 0;
                    obj.WebsiteList{id}.BuildPDF(); 
                end
            else
                obj.IsOpenWorld = 0;
            end
            
        end
        
        % evaluate the entropy of Samples
        % webIdx = 0:       evaluate all
        % otherwise:        evaluate webIdx website
        % 
        % instIdx:          index range of instances to evaluate
	% [] indicates evaluating all samples under the website		
        
        function whole_ent = Evaluate(obj, webIdx, instIdx)
            
            %display('Start Evaluate Samples...');
            web_num = length(obj.SampleList); 
            whole_ent = cell(1, web_num);            
            
            if webIdx == 0 
                Evalist = 1:web_num;
            else
                Evalist = webIdx;
            end
            
            for wi = Evalist 
                %disp(['Evaluate Samples from Website ', int2str(wi)]);
                % get number of instances for each web
                maxnum_inst = obj.GetWebSamplenum(wi);
                web_ent = zeros(maxnum_inst, 1);
                
		% if instIdx = [], evaluate all under this website
		if length(instIdx) == 0
			instIdx_perweb = 1:maxnum_inst;
		else
			instIdx_perweb = instIdx;
		end
                for each_inst = instIdx_perweb
                    
                    % if each_inst out the range
                    if each_inst <= maxnum_inst
                        % each instance
                        log_prob = zeros(1, web_num);
                        for each_web = 1:web_num
                            log_prob(each_web) = obj.WebsiteList{each_web}.Evaluate(obj.SampleList{wi}(each_inst,:));
                        end
                    
                        % translate log probabilities into entropy
                        web_ent(each_inst) = Entropy(log_prob, obj.prior, obj.MonitorFlag);
                    end
                end
                whole_ent{wi} = web_ent;
            end
            
        end
        
        
        function whole_collect = evaluateKernel(obj, webIdx, instIdx)
            
            %display('Start Evaluate Samples...');
            web_num = length(obj.SampleList); 
            whole_collect = cell(1, web_num);            
            
            if webIdx == 0 
                Evalist = 1:web_num;
            else
                Evalist = webIdx;
            end
            
            for wi = Evalist 
                %disp(['Evaluate Samples from Website ', int2str(wi)]);
                % get number of instances for each web
                maxnum_inst = obj.GetWebSamplenum(wi);
                web_collect = cell(maxnum_inst, 1);
                
		% if instIdx = [], evaluate all under this website
		if length(instIdx) == 0
			instIdx_perweb = 1:maxnum_inst;
		else
			instIdx_perweb = instIdx;
		end
                for each_inst = instIdx_perweb
                    
                    % if each_inst out the range
                    if each_inst <= maxnum_inst
                        % each instance
                        log_prob = zeros(1, web_num);
                        for each_web = 1:web_num
                            log_prob(each_web) = obj.WebsiteList{each_web}.Evaluate(obj.SampleList{wi}(each_inst,:));
                        end
                    
                        % translate log probabilities into entropy
                        web_collect{each_inst} = log_prob;
                    end
                end
                whole_collect{wi} = web_collect;
            end
            
        end



        % given webIdx, return how many samples for it
        function res = GetWebSamplenum(obj, webIdx)
            res = size(obj.SampleList{webIdx}, 1);
        end
        
        
        
        % Generate Samples, for Evaluate function
        % num:  total sample number, the true number may be more
        function GenerateSamples(obj, TotalNum)
            %display('Generate Samples');
            web_num = length(obj.WebsiteList);
            obj.SampleList = cell(web_num, 1);
            for id = 1:web_num
                per_num = ceil( TotalNum*obj.prior(id) );
                obj.SampleList{id} = obj.WebsiteList{id}.Sampling(per_num);
            end
        end
        
        % set samples directly
        function SetSampleList(obj, MySamples)
            obj.SampleList = MySamples;
        end
        
        % get samples: return obj.SampleList
        function Res = GetSampleList(obj)
            Res = obj.SampleList;
        end
        
        
        % return averaged mutual information matrix
        % webList: control WHICH websites to measure upon (1,2,3,....)
        function ave = MI(obj, normalize_flag, webList, measureMatrix)
            
            % MI measure requires including all features into info
            % check whether all features are included for MI
            
            if(length(obj.original_vector) ~= length(obj.model_vector))
                error('MI Error: not all features are included!');
            end
            
            
            if length(webList) == 0
                % measure ALL websites
                webList = 1:length(obj.WebsiteList);
            end
            
            if sum ( sum(measureMatrix~=0) ) == 0
                % nothing to compute
                ave = measureMatrix + NaN;
            else
                % have things to compute
                WL = obj.WebsiteList;
                parfor i = 1:length(WL)
                    % webIdx = webList(i);
                    % mi{i} = obj.WebsiteList{webIdx}.MI(normalize_flag, measureMatrix);
                    if sum(webList == i) ~= 0
                        % i is in webList
                        temp = WL{i};
                        mi{i} = temp.MI(normalize_flag, measureMatrix);
                    end
                end
                
                % average mi
                acc = zeros(obj.feature_num, obj.feature_num);
                for i = webList
                    acc = acc + mi{i};
                end
                ave = acc./length(webList);
            end
        end
        
        % reModel: for bootstrap/subsampling
        function reModel(obj, krate, selector)
            web_num = length(obj.WebsiteList);
            for id = 1:web_num
                obj.WebsiteList{id}.reModel(krate, selector);
            end
        end
        
        
    end    
    
end



