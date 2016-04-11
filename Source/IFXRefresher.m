// IFXRefresher.m
//
// Copyright (c) 2016–2021 ShandaGames (http://www.sdo.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IFXRefresher.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, IFXRefresherShowType) {
    IFXRefresherShowTypeUnknown = 0,
    IFXRefresherShowTypePresented,
    IFXRefresherShowTypeNavi,
    IFXRefresherShowTypeTabbar,
    IFXRefresherShowTypeSplit,
};

@interface IFXRefresher ()
@property(nonatomic, assign) IFXRefresherShowType curViewControllerShowType;
@property(nonatomic, weak) UIViewController *curViewController;
@property(nonatomic, strong) NSMutableDictionary *configuredVCAndParams;
@property(nonatomic, strong) NSString *defaultParameterPrefix;
@end

@implementation IFXRefresher

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self.class new];
    });

    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _configuredVCAndParams = [NSMutableDictionary dictionary];
        _defaultParameterPrefix = @"with_";
    }
    return self;
}

+ (void)startMonitor {
#ifdef DEBUG
    [[IFXRefresher sharedInstance] startMonitor];
#endif
}

+ (void)addViewControllerName:(NSString *)vcName withParamNames:(NSArray *)pNames {
#ifdef DEBUG
    [[IFXRefresher sharedInstance] addViewControllerName:vcName withParamNames:pNames];
#endif
}

+ (void)addViewController:(UIViewController *)vc withParamNames:(NSArray *)pNames {
#ifdef DEBUG
    [self addViewControllerName:NSStringFromClass([vc class]) withParamNames:pNames];
#endif
}

+ (void)addViewControllerClass:(Class)clazz withParamNames:(NSArray *)pNames {
#ifdef DEBUG
    [self addViewControllerName:NSStringFromClass(clazz) withParamNames:pNames];
#endif
}

- (void)startMonitor {
    NSLog(@"#IFXRefresher# start");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentVC) name:@"INJECTION_BUNDLE_NOTIFICATION" object:nil];
}

- (void)refreshCurrentVC {
    [self findCurViewControllerAndShowType];
    
    NSMutableSet *pNames = [self getParamNames:[self.curViewController class]];
    [self addBuildInParamNames:pNames];
    NSDictionary *params = [self getParams:self.curViewController byNames:pNames];
    
    NSLog(@"#IFXRefresher# ViewController[%@] paramNames[%@]", [self.curViewController class], params);
    [self refreshViewController:self.curViewController withParams:params];
}

- (NSMutableSet *)getParamNames:(Class)clazz {
    NSMutableSet *pNames = [NSMutableSet set];
    NSMutableArray *pNameArray = self.configuredVCAndParams[NSStringFromClass(clazz)];
    [pNames addObjectsFromArray:pNameArray];
    if (pNameArray == nil || pNameArray.count == 0) {
        [self getParamNames:[self.curViewController class] toSet:pNames];
    }
    return pNames;
}

- (void)addBuildInParamNames:(NSMutableSet *)pNames {
    [pNames addObjectsFromArray:@[@"hidesBottomBarWhenPushed", @"title", @"prefersStatusBarHidden"]];
}

- (void)getParamNames:(Class)clazz toSet:(NSMutableSet *)nameSet {
    if ([clazz isEqual:[UIViewController class]]
            || [clazz isEqual:[UINavigationController class]]
            || [clazz isEqual:[UITabBarController class]]
            || [clazz isEqual:[UITableViewController class]]) {
        return;
    }

    unsigned int outCount, i;
    objc_property_t *parameters = class_copyPropertyList(clazz, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t parameter = parameters[i];
        const char *charParamName = property_getName(parameter);
        NSString *paramName = [NSString stringWithUTF8String:charParamName];
        if ([paramName rangeOfString:self.defaultParameterPrefix].length > 0) {
            [nameSet addObject:paramName];
        }
    }
    free(parameters);
    
    //sometimes config vc is a base controller
    NSArray *basePNames = self.configuredVCAndParams[NSStringFromClass(clazz)];
    if(basePNames){
        [nameSet addObjectsFromArray:basePNames];
    }
    [self getParamNames:[clazz superclass] toSet:nameSet];
}

- (NSDictionary *)getParams:(UIViewController *)vc byNames:(NSSet *)names {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *pName in names) {
        //for objc call swift vc
        @try {
            id value = [vc valueForKey:pName];
            if (value != nil) {
                params[pName] = value;
            }
        }
        @catch (NSException *e) {
        }
    }
    return params;
}

- (void)refreshViewController:(UIViewController *)vc withParams:(NSDictionary *)properties {
    UIViewController *newVC = (UIViewController *) [[[vc class] alloc] init];
    for (NSString *key in [properties allKeys]) {
        //for objc call swift vc
        @try {
            [newVC setValue:properties[key] forKey:key];
        }
        @catch (NSException *e) {
        }
    }

    switch (self.curViewControllerShowType) {
        case IFXRefresherShowTypeNavi: {
            UINavigationController *navVC = vc.navigationController;
            [navVC popViewControllerAnimated:NO];
            [navVC pushViewController:newVC animated:NO];
        }
            break;

        case IFXRefresherShowTypePresented: {
            [vc dismissViewControllerAnimated:NO completion:nil];
            UIViewController *presentingVC = vc.presentingViewController;
            [presentingVC presentViewController:newVC animated:NO completion:nil];
        }
            break;

        case IFXRefresherShowTypeSplit: {
            NSLog(@"#IFXRefresher# IFXRefresherShowTypeSplit not support");
        }
            break;

        case IFXRefresherShowTypeTabbar: {
            UITabBarController *tabbarVC = vc.tabBarController;
            NSArray *array = tabbarVC.viewControllers;
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:array];
            NSUInteger index = [array indexOfObject:vc];
            mutableArray[index] = newVC;
            tabbarVC.viewControllers = mutableArray;
            tabbarVC.selectedIndex = index;
        }
            break;

        case IFXRefresherShowTypeUnknown: {
            NSLog(@"#IFXRefresher# IFXRefresherShowTypeUnknown not support");
        }
        default:
            break;
    }

}

- (void)findCurViewControllerAndShowType {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.curViewController = [self findBestViewController:viewController];
}

- (UIViewController *)findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        self.curViewControllerShowType = IFXRefresherShowTypePresented;
        return [self findBestViewController:vc.presentedViewController];
    }

    if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController *) vc;
        self.curViewControllerShowType = IFXRefresherShowTypeSplit;
        if (svc.viewControllers.count <= 0) {
            return vc;
        }

        return [self findBestViewController:svc.viewControllers.lastObject];
    }

    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *svc = (UINavigationController *) vc;
        self.curViewControllerShowType = IFXRefresherShowTypeNavi;
        if (svc.viewControllers.count <= 0) {
            return vc;
        }

        return [self findBestViewController:svc.topViewController];
    }

    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *svc = (UITabBarController *) vc;
        self.curViewControllerShowType = IFXRefresherShowTypeTabbar;
        if (svc.viewControllers.count <= 0) {
            return vc;
        }

        return [self findBestViewController:svc.selectedViewController];
    }

    self.curViewControllerShowType = self.curViewControllerShowType ?: IFXRefresherShowTypeUnknown;
    return vc;
}

- (void)addViewControllerName:(NSString *)vcName withParamNames:(NSArray *)pNames {
    self.configuredVCAndParams[vcName] = pNames;
}

@end

