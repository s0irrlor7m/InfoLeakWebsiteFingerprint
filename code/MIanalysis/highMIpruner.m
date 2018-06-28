classdef highMIpruner < handle
   properties
       % MI of first website
       THRES
       STEP
       MIgene
       
       mi
       tfnum
   end
   
   
   methods
       function obj = highMIpruner(MIg)
			
           % record a MIgenerator
           obj.MIgene = MIg;
           obj.THRES = readParam('MI_THRES');
           obj.STEP = readParam('STEP');
           obj.tfnum = obj.MIgene.total_feature_num;
           obj.mi = NaN(obj.tfnum, obj.tfnum);

       end
       
       
       
       
       % sortFlist:     sorted list of features by their entropy
       % topMax:        topMax number of features excluding high-MI pairs
       % return:        topMaxFeatureList
       %                topMaxMI
       function topMaxFeatureList = run(obj, sortFlist, topMax)
       
           
           fnum = length(sortFlist);
           
           highMIvec = NaN(1, obj.tfnum);
           
           for i = 1:ceil(fnum/obj.STEP)
               st = 1;
               ed = min(obj.STEP*i, fnum);
               tempList = sortFlist(st:ed);
               
               
               % prune tempList before feeding to compute MI
               % before filter
               disp(['before filter: ']); disp(tempList);
               tempList = obj.filterHighMI(tempList);
               %[tempList, highMIvec] = obj.detectHighMI(tempList, highMIvec);
               disp(['after filter: ']); disp(tempList);

               
               t1 = clock;
               obj.computeMI( tempList );
               t2 = clock;
               disp(['    computeMI[', num2str(i), ']: ', num2str( etime(t2,t1) )]);
               cnum = obj.getCleanNum( tempList );
               if cnum >= topMax
                   break;
               end
           end
           
           [topMaxFeatureList, topMaxMI] = obj.pickTopMax(tempList, topMax);
       end
       
       
       
       
       function clean_list = filterHighMI(obj, sortFlist)
           [clean_list, prune_list] = obj.pruneHighMI(sortFlist, -1);
       end
       
       
       
       
       
       
       
       
       
       % this function give back the pruned flist
       function [clean_flist, highMIvec] = detectHighMI(obj, flist, highMIvec)
           
           % firstly filter by highMIvec
           clean_flist = [];
           
           for i = flist
               if isnan( highMIvec(i) ) == 1
                   clean_flist = [clean_flist, i];
               end
           end
           
           % check from first website
  
           measureMatrix = zeros(obj.tfnum, obj.tfnum);
           
           for i = clean_flist
               for j = clean_flist
                   measureMatrix(i,j) = 1;
               end
           end
          
           % disp(['computeMI:Part1: ', num2str( etime(t2,t1) )]);
           
           resultmi = obj.MIgene.run(measureMatrix, [1]);
           
           % regenerate measureMatrix
           % generate tempVec first
           measureMatrix = zeros(obj.tfnum, obj.tfnum);
           tempVec = NaN(1, obj.tfnum);
           
           for i = 1:length(clean_flist)
               fidx1 = clean_flist(i);
               if isnan( tempVec(fidx1) ) == 0
                   % has been pruned
                   continue;
               end
               %  to prune later features
               for j = (i+1):length(clean_flist)
                   fidx2 = clean_flist(j);
                   if( resultmi(fidx1, fidx2) > obj.THRES )
                       tempVec(fidx2) = fidx1;
                   end
                   
               end
           end
           
           % generate measureMatrix based on tempVec
           for i = 1:length(tempVec)
               fidx1 = i;
               if isnan( tempVec(fidx1) ) ~= 1
                   % find a pair
                   fidx2 = tempVec(fidx1);
                   measureMatrix(fidx1, fidx2) = 1;
                   measureMatrix(fidx2, fidx1) = 1;
               end
           end
           
           
           % run for every website
           resultmi = obj.MIgene.run(measureMatrix, []);
           
           % prune, update clean_list, highMIvec
           for i = 1:length(tempVec)
               fidx1 = i;
               if isnan( tempVec(fidx1) ) ~= 1
                   % find a pair
                   fidx2 = tempVec(fidx1);
                   if resultmi(fidx1,fidx2) > obj.THRES
                       % to prune fidx1
                       clean_flist(clean_flist==fidx1) = [];
                       highMIvec(fidx1) = fidx2;
                   end
               end
           end
           
           
           
           
       end
       
       
       
       
       function cnum = getCleanNum(obj, sortFlist)
           t1 = clock;
           
           [cleanList, prunList] = obj.pruneHighMI(sortFlist, obj.tfnum);
           cnum = length(cleanList);
           t2 = clock;
           disp(['    getCleanNum: ', num2str(cnum), ' with time cost ', num2str( etime(t2,t1) )]);
       end
       
       function [topMaxFeatureList, topMaxMI] = pickTopMax(obj, sortList, topMax)
           [cleanList, prunList] = obj.pruneHighMI(sortList, topMax);
           topMaxFeatureList = cleanList;
           topMaxMI = obj.mi;
       end
       
       
       
       % get top n features that are NOT high MI
       % cleanList would be length n
       % prunList records the pruned features
       % if n larger than normal, would return less than n features
       function [cleanList, prunList] = pruneHighMI(obj, sortFlist, n)
           fnum = length(sortFlist);
           
           prunList = [];
           cleanList = [];
           
           for i = 1:fnum
               fidx1 = sortFlist(i);
               if sum(prunList == fidx1) > 0
                   % such feature is pruned already
                   continue;
               else
                   % not pruned, add it to cleanList
                   cleanList = [cleanList, fidx1];
                   %%% whether to continue
                   if length(cleanList) == n
                       break;
                   end
               end        
               
               % not pruned, have included, and exclude the high MI other
               for j = (i+1):fnum
                   fidx2 = sortFlist(j);
                   if( obj.mi(fidx1,fidx2) > obj.THRES )
                       % find high MI pair, to prune
                       prunList = [prunList, fidx2];
                   end
               end
               
           end
       
       
       end
       
       
       
       function computeMI(obj, flist)
           measureMatrix = zeros(obj.tfnum, obj.tfnum);
           
           t1 = clock;
           
           for i = flist
               for j = flist
                   if isnan( obj.mi(i,j) ) == 1
                       % is a nan, not measured
                       measureMatrix(i,j) = 1;
                   end
               end
           end
           t2 = clock;
           % disp(['computeMI:Part1: ', num2str( etime(t2,t1) )]);
           
           
           resultmi = obj.MIgene.run(measureMatrix, []);
           
           t3 = clock;
           % disp(['computeMI:Part2: ', num2str( etime(t3,t2) )]);
           
           obj.mergeMI(resultmi);
           
           t4 = clock;
           % disp(['computeMI:Part3: ', num2str( etime(t4,t3) )]);
       end
       
       
       
       %%%% merge obj.mi with resultmi, choose obj.mi as the base
       function mergeMI(obj, resultmi)
           
           for i = 1:obj.tfnum
               for j = 1:obj.tfnum
                   if isnan( obj.mi(i,j) ) == 1
                       % find a nan, to check in resultmi
                       if isnan( resultmi(i,j) ) == 0
                           % find a record in resultmi, then
                           obj.mi(i,j) = resultmi(i,j);
                       end
                   end
               
               end
           end
       
       end
       
       
       %%%%% methods end %%%%%%%%%%
       
   end
end
