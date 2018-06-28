% wrapper for Scheduler
% only pass param to scheduler
function res = WrapperScheduler(keyword, param)

sc_path = 'scheduler.mat';

key = 123;

% create a scheduler object
if strcmp(keyword, 'create')
    % create scheduler
    sc = Scheduler(param);
    save(sc_path, 'sc');
    semaphore('create', key, 1);

    
    
elseif strcmp(keyword, 'exit')
    semaphore('destroy', key);

    
    
else
    % non create, should semaphore and import
    semaphore('wait', key);
    sc = importdata(sc_path);
    
    % modify the scheduler
    if strcmp(keyword, 'popBatchIdx')
        % get a match to work on
       res = sc.popBatchIdx();
    elseif strcmp(keyword, 'getBatch')
        res = sc.getBatch(param);
    elseif strcmp(keyword, 'finishBatch')
        sc.finishBatch(param);
    elseif strcmp(keyword, 'updateTimer')
        sc.updateTimer();
    elseif strcmp(keyword, 'isFinished')
        res = sc.isFinished();
    else
        disp('unidentified keyword!')
    end
    
    % exit with care
    save(sc_path, 'sc');
    semaphore('post', key);

end




end