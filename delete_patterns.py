

import sys
#part of pattern name to delete
patternName=sys.argv[1]

patterns=deployer.virtualsystempatterns[patternName]

for pattern in patterns:
    patternName=pattern.app_name
    patternID=pattern.app_id
    print "Deleting %s..." % patternName
    deployer.virtualsystempatterns.delete(patternID)

