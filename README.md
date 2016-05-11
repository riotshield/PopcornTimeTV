#PopcornTime TV
[![Build Status](https://travis-ci.org/PopcornTimeTV/PopcornTimeTV.svg?branch=master)](https://travis-ci.org/PopcornTimeTV/PopcornTimeTV)

[![Slack Status](https://popcorntimetv.herokuapp.com/badge.svg)](http://popcorntimetv.herokuapp.com)

An Apple TV 4 application to torrent movies and tv shows for streaming.
A simple and easy to use application based on TVML to bring the native desktop
PopcornTime experience to Apple TV.

##Version
Release notes for every version can be found here https://github.com/PopcornTimeTV/PopcornTimeTV/wiki/Release-Notes

##Setup

PopcornTime requires cocoapods. 
To install it simply open Terminal and enter the following command

`gem install cocoapods`

Setting up PopcornTime is quite easy.
*Open Terminal to run the following commands*

```
cd ~/Desktop
git clone https://github.com/PopcornTimeTV/PopcornTimeTV.git
cd ~/Desktop/PopcornTimeTV
git checkout 0.6.0
```
If you are installing PopcornTIme for the first time run 
`pod install` otherwise if you are updating, run `pod update`

If issues persist when installing TVVLC, remove the Pods folder and Podfile.lock and run this command in terminal `rm -rf ~/.cocoapods/repos/popcorntimetv`

**Open the project with**

PopcornTime.xcworkspace

##Screenshots

![Screenshots](http://i.imgur.com/VvRRFCi.jpg)

##Want to help?

Join the project Slack channel and be part of the PopcornTime experience for AppleTV. Designer? Developer? Curious person? You're welcome! Come in and say hello. Want to report a bug, request a feature or even contribute? You can join our community Slack group to keep up-to-date and speak to the team.

If you plan on contributing, make sure to follow along with the guidelines found in the `CONTRIBUTING.md` file.

