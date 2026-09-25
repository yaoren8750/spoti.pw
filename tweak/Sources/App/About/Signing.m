// Whether the lock screen can open this build at all. MediaRemote launches the now playing app by
// the App ID in its application-identifier entitlement, not by CFBundleIdentifier, so a build signed
// under a profile whose App ID is not the bundle id installs and plays but cannot be opened from the
// now playing card: iOS asks for a bundle that is not installed and offers the App Store instead.
// The signature decides this and nothing in the app can change it, so all the mod does is say so --
// once on the first launch under a signature, and from a red row at the top of Mod Settings for as
// long as it lasts. Both land on the same sheet, which names the bundle id to sign under and copies
// it, because that one string is the whole fix.
#import "Core/SGCore.h"
#import "Settings/SGPageStyle.h"
#import "About.h"
#import "App/Onboarding/Onboarding.h"
#import <dlfcn.h>

NSString *const SGSigningHelpURL = @"https://github.com/skopevoj/spoti.pw#signing-it-yourself";

static NSString *const kWarned = @"spotifyglass.signing.warned";
static BOOL sg_fixPending;

// SecTaskCopyValueForEntitlement is not in the iOS SDK, so it is resolved at runtime like the rest
// of the private API the mod uses. A build that cannot read its own entitlement stays quiet.
NSString *SGSigningAppIdentifier(void) {
    static NSString *cached;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        void *security = dlopen("/System/Library/Frameworks/Security.framework/Security", RTLD_LAZY);
        if (!security) return;
        CFTypeRef (*createFromSelf)(CFAllocatorRef) = dlsym(security, "SecTaskCreateFromSelf");
        CFTypeRef (*copyValue)(CFTypeRef, CFStringRef, CFErrorRef *) = dlsym(security, "SecTaskCopyValueForEntitlement");
        if (!createFromSelf || !copyValue) return;
        CFTypeRef task = createFromSelf(NULL);
        if (!task) return;
        CFTypeRef value = copyValue(task, CFSTR("application-identifier"), NULL);
        CFRelease(task);
        if (!value) return;
        if (CFGetTypeID(value) == CFStringGetTypeID()) {
            NSString *identifier = (__bridge NSString *)value;
            NSRange dot = [identifier rangeOfString:@"."];   // drop the team prefix
            cached = dot.location == NSNotFound ? [identifier copy]
                                               : [identifier substringFromIndex:dot.location + 1];
        }
        CFRelease(value);
    });
    return cached;
}

// Unreadable counts as fine: a guess here would cry wolf at a build that works.
BOOL SGSigningOpensFromLockScreen(void) {
    NSString *appID = SGSigningAppIdentifier();
    return !appID || [appID isEqualToString:NSBundle.mainBundle.bundleIdentifier];
}

// The fix is one string, so the sheet leads with it and Copy is the first action: whoever reads this
// is on their way back to Feather to paste it into the identifier field.
static void showFix(void) {
    NSString *appID = SGSigningAppIdentifier();
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier ?: @"?";
    UIViewController *top = SGTopController();
    if (!appID || !top) return;
    NSString *message = [NSString stringWithFormat:
                         @"请使用以下 Bundle ID 重新签名 Spotify：\n\n%@\n\n"
                                 @"如果你使用 Feather，请在 Identifier 字段中填写该 ID；"
                                 @"请关闭 PPQ 保护，否则它会自动追加随机字符串，导致此问题再次出现。\n\n"
                                 @"原因：此版本安装时使用的是 %@，但签名使用的是 App ID %@。"
                                 @"iOS 会根据 App ID 打开正在播放的卡片，因此找不到对应的应用。"
                                 @"Mod 的其他功能不受影响。", appID, bundleID, appID];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"锁屏无法打开 Spotify"
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [sheet addAction:[UIAlertAction actionWithTitle:@"复制bundle id" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIPasteboard.generalPasteboard.string = appID;
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"了解更多" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        SGOpenURL(SGSigningHelpURL);
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [top presentViewController:sheet animated:YES completion:nil];
}

// nil while the signature is sound, which is what keeps the row out of Mod Settings entirely.
SGModRow *SGSigningWarningRow(void) {
    if (SGSigningOpensFromLockScreen()) return nil;
    return SGWarningRow(@"锁屏无法打开 Spotify",
                        @"点击查看解决方法",
                        ^{ showFix(); });
}

// Said once per signature: re-signing under a different App ID is a new mistake and says so again,
// but a build that is simply left broken does not nag on every launch. The row stays either way.
void SGCheckSigningOnce(void) {
    if (SGSigningOpensFromLockScreen()) return;
    NSString *appID = SGSigningAppIdentifier();
    NSUserDefaults *store = NSUserDefaults.standardUserDefaults;
    SGLog(@"signing: installed as %@ but signed under %@; the now playing card cannot open this build",
          NSBundle.mainBundle.bundleIdentifier, appID);
    if ([[store stringForKey:kWarned] isEqualToString:appID]) return;
    [store setObject:appID forKey:kWarned];

    // The first activation, plus a moment for Spotify's own start-up screens to get out of the way.
    __block id token = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                      object:nil
                                                                       queue:nil
                                                                  usingBlock:^(NSNotification *note) {
        [NSNotificationCenter.defaultCenter removeObserver:token];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // The welcome tour has the screen; it shows the fix when it goes.
            if (SGOnboardingShowing()) sg_fixPending = YES;
            else showFix();
        });
    }];
}

void SGShowSigningFixIfPending(void) {
    if (!sg_fixPending) return;
    sg_fixPending = NO;
    showFix();
}
