# NKJMovieComposer

[![CI Status](http://img.shields.io/travis/nakajijapan/NKJMovieComposer.svg?style=flat)](https://travis-ci.org/nakajijapan/NKJMovieComposer)
[![Version](https://img.shields.io/cocoapods/v/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)
[![License](https://img.shields.io/cocoapods/l/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)
[![Platform](https://img.shields.io/cocoapods/p/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)

NKJMovieComposer is very simple movie composer for iOS.

## Requirements

NKJMovieComposer higher requires Xcode 6, targeting either iOS 8.0 and above, or Mac OS 10.10 OS X and above.

* AVFoundation.framework

## Installation

### CocoaPods

```
pod "NKJMovieComposer"
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


