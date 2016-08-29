//
//  UIViewController+IFX.m
//  TestParams
//
//  Created by Don Yang on 8/27/16.
//  Copyright © 2016 dy. All rights reserved.
//

#import "UIViewController+IFX.h"
#import <objc/runtime.h>

@implementation UIViewController (IFX)

#ifdef DEBUG

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load {
    swizzleMethod([self class], @selector(viewDidLoad), @selector(ifx_viewDidLoad));
}

- (void)ifx_viewDidLoad {
    NSLog(@"ifx_viewDidLoad class %@", NSStringFromClass(self.class));
    
    unsigned int outCount, i;
    objc_property_t *parameters = class_copyPropertyList(UIViewController.class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t parameter = parameters[i];
        const char *charParamName = property_getName(parameter);
        NSString *paramName = [NSString stringWithUTF8String:charParamName];
        NSLog(@"property: %@", paramName);
    }
    free(parameters);
    
    [self ifx_viewDidLoad];
}

#endif

@end
