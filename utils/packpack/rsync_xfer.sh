#!/bin/bash

# We don't deploy during eslint checks, so exit immediately
if [ "${DIST}" == "eslint" ]; then
    exit 0
fi

# Check to see if this script has access to all the commands it needs
for CMD in sshfs rsync find fusermount mkdir; do
  type $CMD 2>&1 > /dev/null

  if [ $? -ne 0 ]; then
    echo
    echo "ERROR: The script cannot find the required command \"${CMD}\"."
    echo
    exit 1
  fi
done

# See https://docs.travis-ci.com/user/cron-jobs/
#
# TO-DO: Deploy after ever commit for rpm builds after pacakge signing & repo creation is containerized
#
if [ "${TRAVIS_EVENT_TYPE}" == "cron" ] || [ "${OS}" == "debian" ] || [ "${OS}" == "ubuntu" ]; then

    if [ "${OS}" == "debian" ] || [ "${OS}" == "ubuntu" ]; then
        targetfolder="debian/master/mini-dinstall/incoming"
    else
        targetfolder="travis"
    fi

    echo
    echo "Target subfolder set to $targetfolder"
    echo

    echo "Running \$(rsync -v -e 'ssh -vvv' build/*.{rpm,deb,dsc,tar.xz,changes} zmrepo@zmrepo.zoneminder.com:${targetfolder}/ 2>&1)"
    rsync -v --ignore-missing-args -e 'ssh -vvv' build/*.{rpm,deb,dsc,tar.xz,changes} zmrepo@zmrepo.zoneminder.com:${targetfolder}/ 2>&1
    if [ "$?" -eq 0 ]; then
        echo 
        echo "Files copied successfully."
        echo
    else 
        echo
        echo "ERROR: Attempt to rsync to zmrepo.zoneminder.com failed!"
        echo "See log output for details."
        echo
        exit 99
    fi
fi
