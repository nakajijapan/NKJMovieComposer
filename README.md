# NKJMovieComposer


[![Version](https://img.shields.io/cocoapods/v/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)
[![License](https://img.shields.io/cocoapods/l/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)
[![Platform](https://img.shields.io/cocoapods/p/NKJMovieComposer.svg?style=flat)](http://cocoadocs.org/docsets/NKJMovieComposer)


## Requirements

NKJMovieComposer higher requires Xcode 5, targeting either iOS 7.0 and above, or Mac OS 10.9 OS X Mavericks and above.

* AVFoundation.framework

## Installation

### CocoaPods

```
pod "NKJMovieComposer"
```

## Usage

#### 1.Initialize

```obj-c
    NKJMovieComposer* movieComposition = [[NKJMovieComposer alloc] init];
```

#### 2.Simple Example

```obj-c
    NSURL* movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"movie_file" ofType:@"mov"]];
    [movieComposition addVideoWithURL:movieURL];
```

#### 3.Save File

```obj-c
    // compose
    assetExportSession = [movieComposition readyToComposeVideoWithFilePath:composedMoviePath];
    NSURL *composedMovieUrl = [NSURL fileURLWithPath:composedMoviePath];

    // export
    [assetExportSession exportAsynchronouslyWithCompletionHandler: ^(void ) {

        // save to device
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:composedMovieUrl]) {
            [library writeVideoAtPathToSavedPhotosAlbum:composedMovieUrl
                                        completionBlock:^(NSURL *assetURL, NSError *assetError) {

                                            // something code

                                        }];
        }

    }];
```

## Author

nakajijapan

## License

NKJMovieComposer is available under the MIT license. See the LICENSE file for more info.

