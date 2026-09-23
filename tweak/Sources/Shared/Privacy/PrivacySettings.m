#import "Settings/SGModPage.h"
#import "Privacy.h"

// Every switch here forces a flag Spotify ships on to off, so the titles name the hiding: on hides
// the thing, off is Spotify's own value.
static UIViewController *tipsPage(void) {

    return [[SGModPage alloc] initWithTitle:@"提示"
                                      intro:SGRestartNote sections:@[

        SGSection(@"减少干扰", @[

            SGFlagRow(@"减少干扰", @"ios-messaging-reduceinterventions-impl.enabled"),

        ]),

        SGSection(@"提示信息", @[

            SGKillRow(@"隐藏智能随机播放助手提示", @"ios-messaging-reduceinterventions-impl.enable_message_smart_shuffle_helper_tooltip"),

            SGKillRow(@"隐藏省流量提示", @"ios-feature-nowplayingbar.data_saver_tooltip"),

            SGKillRow(@"隐藏 AI 创建播放列表提示", @"ios-messaging-reduceinterventions-impl.enable_message_your_library_ai_playlist_creation_tooltip"),

            SGKillRow(@"隐藏观看动态探索提示", @"ios-messaging-reduceinterventions-impl.enable_message_watch_feed_entity_explorer_tooltip"),

            SGKillRow(@"隐藏账户切换提示", @"ios-messaging-reduceinterventions-impl.enable_message_account_switching_tooltip"),

            SGKillRow(@"隐藏演唱会通知提示", @"ios-messaging-reduceinterventions-impl.enable_message_live_events_concert_notifications_tooltip"),

            SGKillRow(@"隐藏现场活动提示", @"ios-messaging-reduceinterventions-impl.enable_message_live_events_event_entity_safe_tooltip"),

            SGKillRow(@"隐藏现场活动场馆提示", @"ios-messaging-reduceinterventions-impl.enable_message_live_events_event_entity_venuename_header_tooltip"),

            SGKillRow(@"隐藏 Puffin 优化提示", @"ios-messaging-reduceinterventions-impl.enable_message_puffin_nudge_end_optimization"),

        ]),

    ] footer:nil];

}

static SGModSection *countersSection(void) {

    NSMutableArray<SGModRow *> *counts = [NSMutableArray array];

    for (NSString *label in SGBlockedLabels()) {

        [counts addObject:SGStatRow(label, ^NSString *{

            return @(SGBlockedCount(label)).stringValue;

        })];

    }

    [counts addObject:SGStatRow(@"总计", ^NSString *{

        return @(SGBlockedCount(nil)).stringValue;

    })];

    [counts addObject:SGActionRow(@"重置遥测统计数据", nil, ^{ SGResetBlocked(); })];

    return SGSection(@"已拦截的遥测统计", counts);

}

// 开关优先显示，统计信息放在最后，避免干扰设置项。

UIViewController *SGPrivacySettingsPage(void) {

    return [[SGModPage alloc] initWithTitle:@"隐私与清理"
                                      intro:SGRestartNote sections:@[

        SGSection(@"隐私", @[

            SGWithSymbol(
                SGSwitchRow(@"阻止遥测数据",
                            @"Spotify 自身事件仍会发送，因为「最近播放」依赖这些数据",
                            SGKeyBlockTelemetry),
                @"antenna.radiowaves.left.and.right.slash"),

        ]),

        SGSection(@"清理", @[

            SGWithSymbol(
                SGOptionRow(@"隐藏搜索中的视频轮播",
                            nil,
                            SGKeyHideSearchVideos),
                @"play.rectangle.on.rectangle"),

            SGWithSymbol(
                SGOptionRow(@"隐藏搜索中的社交信息",
                            nil,
                            SGKeyHideSocialProof),
                @"person.2"),

            SGWithSymbol(
                SGPageRow(@"提示",
                          ^UIViewController *{
                              return tipsPage();
                          }),
                @"lightbulb"),

        ]),

        countersSection(),

    ] footer:nil];

}
