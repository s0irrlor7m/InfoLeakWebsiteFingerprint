
# where the original trace data stored
DATASET_PATH = "************"



# turn on/off debug:
DEBUG_FLAG = True


# where the crawling id is stored

ID_PATH = "*****************8"

# turn on/off categories of features 
PACKET_NUMBER = True 
PKT_TIME = True
UNIQUE_PACKET_LENGTH = False
NGRAM_ENABLE = True
TRANS_POSITION = True
PACKET_DISTRIBUTION = True
BURSTS = True
FIRST20 = True
CUMUL = True
FIRST30_PKT_NUM = True
LAST30_PKT_NUM = True
PKT_PER_SECOND = True
INTERVAL_KNN = True
INTERVAL_ICICS = True
INTERVAL_WPES11 = True


# feature parameter

# packet number per second, how many seconds to count?
howlong = 100

# n-gram feature
NGRAM = 3

# CUMUL feature number
featureCount = 100



# normalize traffic, suppose fixed packet length
NormalizeTraffic = 1
TRAFFIC_REFORMAT = 1
