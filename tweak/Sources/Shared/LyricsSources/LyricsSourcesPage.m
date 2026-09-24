#import "Settings/SGOrderPage.h"
#import "LyricsSources.h"

UIViewController *SGLyricsSourcesPage(void) {
    NSMutableArray<SGOrderItem *> *items = [NSMutableArray array];
    for (SGLyricsProvider *provider in SGLyricsAllProviders()) {
        [items addObject:SGOrderItemMake(provider.key, provider.name, provider.detail)];
    }
    return SGOrderPage(@"歌词来源", items, ^NSArray<NSString *> *{ return SGLyricsOrder(); },
                       ^(NSArray<NSString *> *order) { SGLyricsSetOrder(order); },
                       @"按从上到下的顺序请求歌词，直到找到带逐词时间轴的歌词。"
                       "歌词来源只会获取歌曲信息，不会获取你的账户信息。");
}
