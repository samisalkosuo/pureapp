

import sys
import os
#part of pattern name to export

#import all pattern dirs in dir
#ls -1 patterns | awk '{print "./pureconsole.sh -f import_pattern_dir.py patterns/" $1}'

patternDir=sys.argv[1]
if not os.path.exists(patternDir):
	print "Pattern dir does not exist."
	sys.exit(1)

print "Importing %s..." % patternDir
deployer.import_artifacts(patternDir)


