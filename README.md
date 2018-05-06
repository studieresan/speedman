# speedman
> "The distant future"

This is the native iOS app of Studs 2018, written in Swift 4.  
It allows Studs members to view event information and check in to events.

## Getting Started
### Prerequisites
This project uses [Cocoapods](http://cocoapods.org/) for dependency management.
Dependencies are declared in the `Podfile`. 

```shell
# Installing Cocoapods for Xcode 8 + 9
$ sudo gem install cocoapods
```

### Installing
```shell
# Clone the repo
$ git clone https://github.com/studieresan/speedman.git

$ cd speedman

# Install dependencies with Cocoapods
$ pod repo update
$ pod install

# Open the workspace in Xcode (Not .xcodeproj/ !)
$ open Studs.xcworkspace/
```

#### Overlord
The app communicates with the Studs18 backend, [overlord](https://github.com/studieresan/overlord).  
Point the app to a running instance in `Studs/API.js`.

#### Firebase
This project uses Firebase for some realtime functionality. In order for this to work, download and include the [GoogleService-Info.plist](https://support.google.com/firebase/answer/7015592) available in the Firebase Console.  
Drop it into the `Studs/ ` directory.

## Built With
* [Alamofire](https://github.com/Alamofire/Alamofire) - HTTP Networking
* [1Password App Extension](https://github.com/AgileBits/onepassword-app-extension) - Credentials autofilling for 1Password users
* [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore/) - Realtime database
* [Pulley](https://github.com/52inc/Pulley) - Drawer UI used in trip mode
