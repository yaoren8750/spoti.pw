// The redesign's copy of Native/Appearance/EdgeEffect.x.
// Soft top edge: iOS 27 resolves a scroll view's automatic top edge effect to the hard style, the
// flat dark band under the navigation bar (UIKit.ScrollEdgeEffectView in trees/continuous/1.txt).
// Setting the soft style brings back iOS 26's thin fading blur. Set on every layout pass as well as
// on arrival, in case UIKit resolves the style again after the page appears.
#import <objc/runtime.h>
#import "Core/SGCore.h"
#import <objc/message.h>

@interface UIScrollEdgeEffect : NSObject
@property(nonatomic, strong) id sgr_style;
@end

@interface UIScrollView (EdgeEffectPrivate)
@property(nonatomic, strong) id sgr_topEdgeEffect;
@end

static void soften(UIScrollView *scrollView) {
    if (@available(iOS 26.0, *)) {
        // The style last set here, so a layout pass the setter itself causes does not set it again.
        static char setKey;
        UIScrollEdgeEffect *top = scrollView.topEdgeEffect;
        if (top.style == objc_getAssociatedObject(scrollView, &setKey)) return;
        Class styleClass = NSClassFromString(@"UIScrollEdgeEffectStyle");

id soft = nil;

if (styleClass) {
    SEL sel = NSSelectorFromString(@"softStyle");

    if ([styleClass respondsToSelector:sel]) {
        soft = ((id (*)(id, SEL))objc_msgSend)(styleClass, sel);
    }
}

if (!soft)
    return;

[top setValue:soft forKey:@"style"];
        objc_setAssociatedObject(scrollView, &setKey, top.style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        static dispatch_once_t once;
        dispatch_once(&once, ^{ SGLog(@"soft top edge: first scroll view %@", NSStringFromClass(scrollView.class)); });
    }
}

%hook UIScrollView
- (void)didMoveToWindow {
    %orig;
    if (self.window) soften(self);
}

- (void)layoutSubviews {
    %orig;
    if (self.window) soften(self);
}
%end

%ctor {
    if (!SGRedesignedUI()) return;
    %init;
}
