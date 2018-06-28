# the feature extraction script
# include a complete list of features in the Tor website fingerprinting literature

from __future__ import division

import os 
import sys
import util
from Param import *


# for CUMUL features and std
import itertools
import numpy

# for int/int to be float


from FeatureUtil import *

import multiprocessing 

#keyword = sys.argv[1]

# used for celltrace function
#CelltracePath_crawl = util.PathReader(keyword)


CelltracePath_List = []

#for each in CelltracePath_crawl:
#  CelltracePath_List.append(each)




# Content Analysis


CelltracePath_List.append("******************")

CelltracePath = ""
FeaturePath = CelltracePath 





# create a celltrace file in corresponding folder
# return the path of the created file
def CreateFile(DirFile):
  global FeaturePath
  global CelltracePath

  Filename = os.path.basename(DirFile)
  AbsPath = os.path.dirname(DirFile)
#  RelPath = os.path.relpath(AbsPath, FeaturePath)

#  print Filename, AbsPath, RelPath  

  NewName = Filename.split(".")[0] + ".feature"
  DestPath = os.path.join(FeaturePath, NewName)

  # create folder if nonexist
  DestDir = os.path.dirname(DestPath)
  if not os.path.exists(DestDir):
    os.makedirs(DestDir)

  fd = open(DestPath, "w+")
  fd.close()
  return DestPath


def Enumerate(Dir):
  FileList = []
  for dirname, dirnames, filenames in os.walk(Dir):
    # skip logs directory
    if "logs" in dirnames:
      dirnames.remove("logs")
    # if file exists
    if len(filenames) != 0:
      for filename in filenames:
        fulldir = os.path.join(dirname, filename)
        FileList.append(fulldir)
  return FileList



def extract(times, sizes, features):




	if DEBUG_FLAG:
		FeaturePos = dict()

	#Transmission size features
	if PACKET_NUMBER == True:
		PktNum.PacketNumFeature(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['PACKET_NUMBER'] = len(features)
	
	# inter packet time + transmission time feature
	if PKT_TIME == True: 
		Time.TimeFeature(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['PKT_TIME'] = len(features)

	#Unique packet lengths
	if UNIQUE_PACKET_LENGTH == True:
		PktLen.PktLenFeature(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['UNIQUE_PACKET_LENGTH'] = len(features)

	# n-gram feature for ordering
	if NGRAM_ENABLE == True:
		buckets = Ngram.NgramExtract(sizes, 2)
		features.extend(buckets)
		buckets  = Ngram.NgramExtract(sizes, 3)
		features.extend(buckets)
		buckets = Ngram.NgramExtract(sizes, 4)
		features.extend(buckets) 
		buckets = Ngram.NgramExtract(sizes, 5)
		features.extend(buckets)
		buckets = Ngram.NgramExtract(sizes, 6)
		features.extend(buckets)
		if DEBUG_FLAG:
			FeaturePos['NGRAM'] = len(features)

	# trans position features
	if TRANS_POSITION == True:
		TransPosition.TransPosFeature(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['TRANS_POSITION'] = len(features)
		
	if INTERVAL_KNN == True:
		Interval.IntervalFeature(times, sizes, features, 'KNN')
		if DEBUG_FLAG:
			FeaturePos['INTERVAL_KNN'] = len(features)
	if INTERVAL_ICICS == True:
		Interval.IntervalFeature(times, sizes, features, 'ICICS')
		if DEBUG_FLAG:
			FeaturePos['INTERVAL_ICICS'] = len(features)
	if INTERVAL_WPES11 == True:
		Interval.IntervalFeature(times, sizes, features, 'WPES11')
		if DEBUG_FLAG:
			FeaturePos['INTERVAL_WPES11'] = len(features)
	    
	#Packet distributions (where are the outgoing packets concentrated) (knn + k-anonymity)
	if PACKET_DISTRIBUTION == True:
		PktDistribution.PktDistFeature(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['PKT_DISTRIBUTION'] = len(features)

	#Bursts (knn)
	if BURSTS == True:
		Burst.BurstFeature(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['BURST'] = len(features)

	# first 20 packets (knn)
	if FIRST20 == True:
		HeadTail.First20(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['FIRST20'] = len(features)

	# first 30: outgoing/incoming packet number (k-anonymity)
	if FIRST30_PKT_NUM:
		HeadTail.First30PktNum(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['FIRST30_PKT_NUM'] = len(features)

	# last 30: outgoing/incoming packet number (k-anonymity)
	if LAST30_PKT_NUM:
		HeadTail.Last30PktNum(times, sizes, features)
		if DEBUG_FLAG:
			FeaturePos['LAST30_PKT_NUM'] = len(features)

	# packets per second (k-anonymity)
	# plus alternative list
	if PKT_PER_SECOND:
		PktSec.PktSecFeature(times, sizes, features, howlong)
		if DEBUG_FLAG:
			FeaturePos['PKT_PER_SECOND'] = len(features)

	# CUMUL features
	if CUMUL == True:
		features.extend( Cumul.CumulFeatures(sizes, featureCount) )
		if DEBUG_FLAG:
			FeaturePos['CUMUL'] = len(features)
	
	if DEBUG_FLAG:
		# output FeaturePos
		fd = open('FeaturePos', 'w')
		newfp = sorted(FeaturePos.items(), key=lambda i:i[1])
		for each_key, pos in newfp:
			fd.write(each_key + ':' + str(pos) + '\n')
		fd.close()

def BatchHandler(FileList):
  for each_file in FileList:
    if ".feature" in each_file:
      continue
#    print each_file
    f = open(each_file, "r")
    try:
      times = []
      sizes = []
      for x in f:
        if TRAFFIC_REFORMAT:
          x = util.TrafficReformat(x)
        else:
          x = x.split("\t")
  #      print x
  #      print x[0]
  #      print x[1]
        times.append(float(x[0]))
        sizes.append(int(x[1]))
    except:
        f.close()
        continue
    f.close()
    
    # whether times or size is empty
    if len(times) == 0 or len(sizes) == 0:
      continue
    
    # whether normalize traffic
    if NormalizeTraffic == 1:
        util.NormalizeTraffic(times, sizes)

    features = []
    try:
      extract(times, sizes, features)
    except:
      print "error occured:", each_file
      continue
    
    Dest = CreateFile(each_file)
    #print Dest
    fout = open(Dest, "w")
    for x in features:
      # x could be str (DEBUG)
      if isinstance(x, str):
        if '\n' in x:
          fout.write(x)
        else:
          fout.write(x + " ")
      else:
        fout.write(repr(x) + " ")
    fout.close()






def main():
  global CelltracePath
  FileList = Enumerate(CelltracePath)

  # split into BATCH_NUM files
  BATCH_NUM = 32 
  FlistBatch = [[]]*BATCH_NUM 
  for idx, each_file in enumerate(FileList):
    bdx =  idx % BATCH_NUM
    FlistBatch[bdx].append(each_file)

  # start BATCH_NUM processes for computation
  pjobs = []
  for i in range(BATCH_NUM):
    p = multiprocessing.Process(target=BatchHandler, args=(FlistBatch[i],))  
    pjobs.append(p)
    p.start()

  for eachp in pjobs:
    eachp.join() 
  print "finished!"


if __name__ == "__main__":
  for each_path in CelltracePath_List:
    CelltracePath = each_path
    print each_path
    FeaturePath = each_path
    main()
