/*
 * Copyright (c) 2011 Joshua V Dillon
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the
 * following conditions are met:
 *  * Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *  * Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *  * Neither the name of the author nor the names of its
 *    contributors may be used to endorse or promote products
 *    derived from this software without specific prior written
 *    permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY JOSHUA V DILLON ''AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOSHUA
 * V DILLON BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


/*
 * This code can be compiled from within Matlab or command-line, assuming the
 * system is appropriately setup.  To compile, invoke:
 *
 * For 32-bit machines:
 *     mex -O -v semaphore.c
 * For 64-bit machines:
 *     mex -O -v semaphore.c
 *
 */


/* 
 * Programmer's Notes:
 *
 * MEX C API:
 * http://www.mathworks.com/access/helpdesk/help/techdoc/apiref/bqoqnz0.html
 *
 * Testing:
 *
 */


#include <sys/shm.h>
#include <semaphore.h>
#include <errno.h>

/* standard mex include */
#include "mex.h"

/* max length of directive string */
#define MAXDIRECTIVELEN 256


/* ------------------------------------------------------------------------- */
/* Matlab gateway function                                                   */
/*                                                                           */
/* (see semaphore.m for description)                                      */
/* ------------------------------------------------------------------------- */
void mexFunction( int nlhs,       mxArray *plhs[], 
                  int nrhs, const mxArray *prhs[]  )
{
	/* for storing directive (string) input */
	char directive[MAXDIRECTIVELEN+1];

    /* for working with shared memory and semaphores */
	key_t  semkey=0;
	int    semval;
	int    semid;
	int    semflg=0644; /* default */
	sem_t *sem=NULL;

	/* check min number of arguments */
	if ( nrhs<2 )
		mexErrMsgIdAndTxt("MATLAB:semaphore",
				"Minimum input arguments missing; must supply directive and key.");

	/* get directive (ARGUMENT 0) */
	if ( mxGetString(prhs[0],(char*)(&directive),MAXDIRECTIVELEN)!=0 )
		mexErrMsgIdAndTxt("MATLAB:semaphore",
				"First input argument must be one of {'create','wait','post','destroy'}.");

	/* get key (ARGUMENT 1) */
	if ( mxIsNumeric(prhs[1]) && mxGetNumberOfElements(prhs[1])==1 )
		semkey = (key_t)mxGetScalar(prhs[1]);
	else
		mexErrMsgIdAndTxt("MATLAB:semaphore",
				"Second input argument must be a valid key (numeric scalar).");

	/* check outputs */
	if ( nlhs > 1 )
		mexErrMsgIdAndTxt("MATLAB:semaphore",
				"Function returns only one value.");

	/* clone, attach, detach, free */
	switch ( tolower(directive[0]) ) {

	/* --------------------------------------------------------------------- */
	/*    Create                                                             */
	/* --------------------------------------------------------------------- */
	case 'c':

		/* Assign Input Parameters */
		if ( nrhs>2 && mxIsNumeric(prhs[2]) && mxGetNumberOfElements(prhs[2])==1 )
			semval = (int)mxGetScalar(prhs[2]);
		else
			mexErrMsgIdAndTxt("MATLAB:semaphore:create",
					"Third input argument must be initial semaphore value (numeric scalar).");

        /* create the shared memory segment */
		semflg = semflg|IPC_CREAT|IPC_EXCL;
        if ( (semid=shmget(semkey,sizeof(sem_t),semflg )) < 0 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:create",
         	       "Unable to create shared memory segment.");

        /* attach the shared memory segment to this dataspace */
        sem = (sem_t*)shmat(semid,NULL,0);
        if ( sem==(sem_t*)-1 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:create",
            	    "Unable to attach shared memory to data space.");

		/* create semaphore */
		if ( (semflg=sem_init(sem,1,semval)) < 0 )
			mexErrMsgIdAndTxt("MATLAB:semaphore:create",
					"Unable to create semaphore.");

		/* assign the output */
		plhs[0] = mxCreateDoubleScalar((double)semflg);

		break;

	/* --------------------------------------------------------------------- */
	/*    Wait                                                               */
	/* --------------------------------------------------------------------- */
	case 'w':

        /* locate the shared memory segment */
        if ( (semid=shmget(semkey,sizeof(sem_t),semflg)) < 0 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:wait",
            	    "Unable to locate shared memory segment.");

        /* attach the shared memory segment to this dataspace */
        sem = (sem_t*)shmat(semid,NULL,0);
        if ( sem==(sem_t*)-1 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:wait",
                	"Unable to attach shared memory to data space.");

		/* wait on the semaphore */
		while ( (semflg=sem_wait(sem)) !=0 )
		{
			/* the lock wasn't acquired */
			if (semflg != EINVAL)
				mexErrMsgIdAndTxt("MATLAB:semaphore:wait",
						"Error wating for semaphore.");
			else
				mexWarnMsgIdAndTxt("MATLAB:semaphore:wait",
						"Wait interrupted; resuming wait.");
		}

		/* detach from the shared memory segment */
		if ( shmdt(sem) != 0 )
			mexErrMsgIdAndTxt("MATLAB:semaphore:wait",
					"Unable to detach shared memory.");

		/* assign the output */
		plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);

		break;

	/* --------------------------------------------------------------------- */
	/*    Post                                                               */
	/* --------------------------------------------------------------------- */
	case 'p':

        /* locate the shared memory segment */
        if ( (semid=shmget(semkey,sizeof(sem_t),semflg)) < 0 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:post",
                	"Unable to locate shared memory segment.");

        /* attach the shared memory segment to this dataspace */
        sem = (sem_t*)shmat(semid,NULL,0);
        if ( sem==(sem_t*)-1 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:post",
	                "Unable to attach shared memory to data space.");

		/* post the semaphore */
        if ( (sem_post(sem)) < 0 ) 
			mexErrMsgIdAndTxt("MATLAB:semaphore:post",
					"Unable to post the semaphore.");

		/* detach from the shared memory segment */
		if ( shmdt(sem) != 0 )
			mexErrMsgIdAndTxt("MATLAB:semaphore:post",
					"Unable to detach shared memory.");

		/* assign the output */
		plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);

		break;

	/* --------------------------------------------------------------------- */
	/*    Destroy                                                            */
	/* --------------------------------------------------------------------- */
	case 'd':

        /* locate the shared memory segment */
        if ( (semid=shmget(semkey,sizeof(sem_t),semflg)) < 0 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:destroy",
                	"Unable to locate shared memory segment.");

        /* attach the shared memory segment to this dataspace */
        sem = (sem_t*)shmat(semid,NULL,0);
        if ( sem==(sem_t*)-1 )
            mexErrMsgIdAndTxt("MATLAB:semaphore:destroy",
	                "Unable to attach shared memory to data space.");

		/* destroy the semaphore */
        if ( (sem_destroy(sem)) < 0 ) 
			mexErrMsgIdAndTxt("MATLAB:semaphore:destroy",
					"Unable to post the semaphore.");

		/* detach from the shared memory segment */
		if ( shmdt(sem) != 0 )
			mexErrMsgIdAndTxt("MATLAB:semaphore:destroy",
					"Unable to detach shared memory.");

		/* free shared memory */
		if ( (shmctl(semid,IPC_RMID,(struct shmid_ds *)NULL)) != 0 )
			mexErrMsgIdAndTxt("MATLAB:semaphore:destroy",
				"Unable to destroy shared memory.");

		/* assign the output */
		plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);

		break;

	/* --------------------------------------------------------------------- */
	/*    Error                                                              */
	/* --------------------------------------------------------------------- */
	default:
		mexErrMsgIdAndTxt("MATLAB:semaphore",
				"Unrecognized directive.");

	} /* end directive switch */

}

