// The Animated lock screen rows, put on the Lock screen widget page by Shared/Player/PlayerSettings.m.
#import "Core/SGCore.h"
#import "Settings/SGModPage.h"
#import "Settings/SGOrderPage.h"
#import "Settings/SGPageStyle.h"
#import "LockScreenArtwork.h"

static void sayWhatIsMissing(void) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"动态锁屏封面"
        message:[NSString stringWithFormat:@"动态封面由锁屏功能提供，iOS 仅从 26 开始支持该功能。"
                 @"当前设备运行 iOS %@，因此封面将保持静态。", UIDevice.currentDevice.systemVersion]
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [SGTopController() presentViewController:alert animated:YES completion:nil];
}

static NSArray<SGOrderItem *> *sources(void) {
    return @[
        SGOrderItemMake(SGArtworkSourceSpotify, @"Spotify Canvas", @"歌曲自带动态片段"),
        SGOrderItemMake(SGArtworkSourceApple, @"Apple Music", @"专辑动态封面"),
    ];
}

NSArray<SGModRow *> *SGAnimatedArtworkRows(void) {
    if (!SGAnimatedArtworkAvailable())
        return @[SGStatActionRow(@"动态锁屏封面", nil, ^NSString *{ return @"需要 iOS 26"; }, ^{ sayWhatIsMissing(); })];
    SGModRow *order = SGPageRow(@"来源", ^UIViewController *{
        return SGOrderPage(@"封面来源", sources(), ^NSArray<NSString *> *{ return SGArtworkOrder(); },
                           ^(NSArray<NSString *> *keys) { SGArtworkSetOrder(keys); },
                           @"按照从上到下的顺序尝试获取封面，直到找到可用动画。Apple Music 仅使用艺人和专辑名称。");
    });
    order.value = ^NSString *{
        NSMutableArray<NSString *> *names = [NSMutableArray array];
        for (NSString *key in SGArtworkOrder()) {
            for (SGOrderItem *item in sources()) {
                if ([item.key isEqualToString:key]) [names addObject:item.name];
            }
        }
        return names.count ? [names componentsJoinedByString:@", "] : @"无";
    };
    order.visible = ^BOOL { return SGFlag(SGKeyLockScreenArtwork, YES); };
    return @[
        SGSwitchRow(@"动态锁屏封面", @"在锁屏控制区域后显示动态封面", SGKeyLockScreenArtwork),
        order,
    ];
}
