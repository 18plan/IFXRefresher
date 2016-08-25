# IFXRefresher
Injection for Xcode auto Refresher, accelerates iOS development. IFXRefresher help us develop iOS UI so much.
It's a tiny library need to work together with Xcode plugin injectionforxcode. IFXRefresher auto refreshs 
running app's current viewcontroller, after we inject source from Xcode.

## Requirements
- Install Xcode plugin injectionforxcode (https://github.com/johnno1962/injectionforxcode)
- iOS 6.0+
- Xcode 7.0+

## Installation
pod 'IFXRefresher', '~>1.1.3'

## Usage
First of all, you should install injectionforxcode Xcode plugin.

To start IFXRefresher
```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [IFXRefresher startMonitor];
    //you code
}
```
Run you app, now you can use "ctrl+=" to refresh you viewcontroller. This refresher is now work for all viewcontroller 
without any start params. But sometime's we need controller with start params. There are two ways to let IFXRefresher  
konw which params we need for current viewcontroller.

- Add all controller start params with prefix 'with_'
- Config manually
```obj-c
[IFXRefresher addViewControllerName:@"viewcontroller name" withParamNames:@[@"param1", @"param2", ...]];
//or
[IFXRefresher addViewController:vc withParamNames:@[@"param1", @"param2", ...]];
//or
[IFXRefresher addViewControllerClass:vcClass withParamNames:@[@"param1", @"param2", ...]];
```
