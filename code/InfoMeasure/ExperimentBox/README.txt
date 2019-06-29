# the parallel version for info measurement


client.py		a client do the evaluation, can support both closed and open world
			(the closed and open world have the same interface)


server.py		split the job and distributes to clients.


client.m can handle whatever info model that is received, no matter it is an closed world or open world model;
server.m transmits the model, split the jobs based on the model, and record the results from the client. also any model it can operate on.

Therefore, extract info generation from the server part. 
server/client is the part independent with the info. 




experiment1:    settting: closed world (100)
                measure each feature's info leakage

experiment2:    setting: closed world (100)
                measure total leakage for top 25 features
