#!/usr/bin/env python

import os
import subprocess
import requests
import json

# Fetch the latest changes
print "# Fetching the latest changes from github..."
os.system("git stash && git fetch && git rebase")

# Fetch the versions
print "\n# Fetching the latest verion info..."
response = requests.get('https://api.github.com/repos/PopcornTimeTV/PopcornTimeTV/releases')
jsonData = json.loads(response.text)
versions = []

for info in jsonData:
    versions.append(str(info["tag_name"]))

# Ask the user what version they want to use
print "\n# What version do you want to checkout? (Latest is at the top)"

for version in versions[:5]:
    print version

version = raw_input("Enter the version number: ")

# Checkout the tag
print "\n# Checking out tag %s..." % version
os.system("git checkout %s && git stash pop" % version)

# Check if cocoapods is installed
podsInstalled = raw_input("Do you have cocoapods installed? (Enter Yes or No): ")
lower = podsInstalled.lower()
if "yes" in lower:
    # Cocoapods already installed
    break
else:
    print "\n# Installing cocoapod gem..."
    os.system("sudo gem install cocoapods")

# Run the cocoapods
print "\n# Updating and installing Cocoapods..."
os.system("pod update")

# OPen Xcode
print "\n# Opening Xcode..."
os.system("open PopcornTime.xcworkspace")

# Thank you message
print "\n# Thanks for installing PopcornTime. WHen a new update is released re-run this script and select the new version."
