// Soft top edge: iOS 27 resolves a scroll view's automatic top edge effect to the hard style, the
// flat dark band under the navigation bar (UIKit.ScrollEdgeEffectView in trees/continuous/1.txt).
// Setting the soft style brings back iOS 26's thin fading blur. Set on every layout pass as well as
// on arrival, in case UIKit resolves the style again after the page appears.
#import <objc/runtime.h>
#import "Core/SGCore.h"

static void soften(UIScrollView *scrollView) {

    if (@available(iOS 26.0, *)) {

        static char setKey;

        Class edgeClass = NSClassFromString(@"UIScrollEdgeEffect");
        Class styleClass = NSClassFromString(@"UIScrollEdgeEffectStyle");

        if (!edgeClass || !styleClass) return;

        id top = [scrollView valueForKey:@"topEdgeEffect"];
        if (!top) return;

        id old = objc_getAssociatedObject(scrollView, &setKey);

        if ([top valueForKey:@"style"] == old)
            return;


        id soft = nil;

        if ([styleClass respondsToSelector:@selector(softStyle)]) {
            soft = [styleClass performSelector:@selector(softStyle)];
        }

        if (!soft)
            return;


        [top setValue:soft forKey:@"style"];

        objc_setAssociatedObject(
            scrollView,
            &setKey,
            soft,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );


        static dispatch_once_t once;

        dispatch_once(&once, ^{
            SGLog(@"soft top edge: %@", NSStringFromClass(scrollView.class));
        });
    }
}


%hook UIScrollView

- (void)didMoveToWindow {

    %orig;

    if (self.window)
        soften(self);
}


- (void)layoutSubviews {

    %orig;

    if (self.window)
        soften(self);
}

%end


%ctor {

    if (!SGNativeUI())
        return;

    %init;
}
