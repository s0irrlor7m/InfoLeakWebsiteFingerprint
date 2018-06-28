from Param import *
import os


def PathReader(keyword):
	
	# ID_PATH is where crawl id are recorded
	global DATASET_PATH, ID_PATH
	f = open(ID_PATH + keyword, 'r')
	crawl = list()
	for each_line in f.readlines():
		path_temp = each_line.strip('\n')[0:-1]
		name = os.path.basename(path_temp)
		crawl.append(DATASET_PATH + keyword + '/' +  name + '/')
	return crawl



# normalize traffic
def NormalizeTraffic(times, sizes):

        # sort
        tmp = sorted(zip(times,sizes))
        
        times = [x for x,_ in tmp]
        sizes = [x for _,x in tmp]

        

        TimeStart = times[0]
        PktSize = 500 
        
        # normalize time
        for i in range(len(times)):
                times[i] = times[i] - TimeStart

        # normalize size
        for i in range(len(sizes)):
                sizes[i] = ( abs(sizes[i])/PktSize )*cmp(sizes[i],0)
        
        # flat it
        newtimes = list()
        newsizes = list()

        for t,s in zip(times, sizes):
                numCell = abs(s)
                oneCell = cmp(s,0)
                for r in range(numCell):
                    newtimes.append(t)
                    newsizes.append(oneCell)
        times = newtimes
        sizes = newsizes
        
# TrafficReformat
def TrafficReformat(line):
    comp = line.split(',')
    time = comp[0]
    pkt = comp[7]
    return [time, pkt]

