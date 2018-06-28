% SEMAPHORE  Interfaces with POSIX semaphore.
%
%   This mex file provides an interface with the POSIX semaphore
%   functionality. For more information, see [1].
%
%   SEMAPHORE('create',KEY,VAL)
%      Initializes a semaphore which can later by accessed by KEY. The
%      argument VAL specifies the initial value for the semaphore.
%
%   SEMAPHORE('destroy',KEY)
%      Destroys the semaphore indexed by KEY. Destroying a semaphore that
%      other processes or threads are currently blocked on (in
%      'wait') produces undefined behavior. Using a semaphore that
%      has been destroyed produces undefined results, until the semaphore
%      has been reinitialized using 'init'.
%
%   SEMAPHORE('wait',KEY)
%      Decrements (locks) the semaphore indexed by KEY. If the
%      semaphore's value is greater than zero, then the decrement
%      proceeds, and the function returns, immediately. If the semaphore
%      currently has the value zero, then the call blocks until either it
%      becomes possible to perform the decrement (i.e., the semaphore
%      value rises above zero), or a signal handler interrupts the call.
%
%   SEMAPHORE('post',KEY)
%      Increments (unlocks) the semaphore indexed by KEY. If the
%      semaphore's value consequently becomes greater than zero, then
%      another process or thread blocked in a 'wait' call will be woken
%      up and proceed to lock the semaphore.
%
%   See also WHOSSHARED, SHAREDMATRIX.
%
%   [1] - http://en.wikipedia.org/wiki/Semaphore_(programming)
%
%   Copyright (c) 2011, Joshua V Dillon
%   All rights reserved.

% Joshua V. Dillon
% jvdillon (a) gmail (.) com
% Wed Aug 10 13:29:01 EDT 2011

% The semaphore documentation (from which this help is generated) is part
% of release 3.27 of the Linux man-pages project. A description of the
% project, and information about reporting bugs, can be found at
% http://www.kernel.org/doc/man-pages/.

