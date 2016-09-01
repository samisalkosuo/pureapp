

import sys
#part of pattern name to export
patternName=sys.argv[1]

exportScriptPackages=False
exportAddons=False
exportImages=False
exportPlugins=False

patterns=deployer.virtualsystempatterns[patternName]

for pattern in patterns:
    patternName=pattern.app_name
    print "Exporting %s..." % patternName
    patternDir=patternName.replace(" ","_")
    directory="./patterns/%s" % patternDir
    if not os.path.exists(directory):
        os.makedirs(directory)
    deployer.export_artifacts(pattern,directory, script_packages=exportScriptPackages, add_ons=exportAddons)

