# NKJMovieComposer

[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CI Status](http://img.shields.io/travis/nakajijapan/NKJMovieComposer.svg?style=flat)](https://travis-ci.org/nakajijapan/NKJMovieComposer)
[![Version](https://img.shields.io/cocoapods/v/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)
[![License](https://img.shields.io/cocoapods/l/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)
[![Platform](https://img.shields.io/cocoapods/p/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)

NKJMovieComposer is very simple movie composer for iOS.


![demo image](./demo.gif)

## Requirements

NKJMovieComposer higher requires Xcode 6, targeting either iOS 8.0 and above, or Mac OS 10.10 OS X and above.

* AVFoundation.framework

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects.
CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod "NKJMovieComposer", '~> 1.0'
```

Then, run the following command:

```
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application.

``` bash
$ brew update
$ brew install carthage
```

To integrate Kingfisher into your Xcode project using Carthage, specify it in your `Cartfile`:

``` ogdl
github "nakajijapan/NKJMovieComposer"
```

Then, run the following command to build the Kingfisher framework:

``` bash
$ carthage update
```


## Usage

#### 1.Initialize

```swift
    let movieComposition = NKJMovieComposer()
```

#### 2.Simple Example

Append Movies.

```swift
        // movie
        let movieURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("movie001", ofType: "mov"))
        layerInstruction = movieComposition.addVideo(movieURL)
```


#### 3.Save File


```swift

        // compose
        self.assetExportSession = movieComposition.readyToComposeVideo(composedMoviePath)
        let composedMovieUrl = NSURL.fileURLWithPath(composedMoviePath)

        // export
        self.assetExportSession.exportAsynchronouslyWithCompletionHandler({() -> Void in


            // save to device
            var library = ALAssetsLibrary()

            if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(composedMovieUrl) {
                library.writeVideoAtPathToSavedPhotosAlbum(composedMovieUrl, completionBlock: {(assetURL, assetError) -> Void in


                     // something code


                })

             }


        })

```

## Author

nakajijapan

## License

NKJMovieComposer is available under the MIT license. See the LICENSE file for more info.
