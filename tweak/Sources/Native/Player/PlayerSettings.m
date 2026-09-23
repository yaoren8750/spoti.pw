// The native player's settings: Spotify's own player screen and the parts of it to hide, and the queue
// and devices flags. The Player page that holds them is App/Pages.m's.
#import "Core/SGCore.h"
#import "Settings/SGModPage.h"
#import "NowPlaying.h"

NSArray<SGModSection *> *SGNativePlayerScreenSections(void) {

    return @[

        SGSection(@"播放界面", @[

            SGOptionRow(@"封面背景", nil, SGKeyPlayerBackdrop),

            SGOptionRow(@"玻璃效果顶部按钮", nil, SGKeyPlayer),

            SGKillRow(@"禁用 Canvas", @"ios-feature-canvas.canvas_enabled"),

            SGFlagRow(@"底部弹层播放器", @"ios-feature-nowplaying.sheet_style_npv"),

            SGFlagRow(@"重新设计的顶部栏", @"ios-feature-nowplaying.new_redesign_header_with_context_menu_enabled"),

            SGFlagRow(@"新版进度条", @"ios-feature-encoreexperiments.new_npv_slider_enabled"),

            SGFlagRow(@"点击展开固定顶部栏", @"ios-feature-nowplaying.expand_sticky_header_on_tap"),

        ]),


        SGSection(@"隐藏播放器下方卡片", @[

            SGHideRow(@"歌词", nil, SGHideLyricsCard),

            SGHideRow(@"关于艺人", nil, SGHideAboutArtist),

            SGHideRow(@"相关视频", nil, SGHideRelatedVideos),

            SGHideRow(@"歌曲信息", nil, SGHideSongDNA),

            SGHideRow(@"直播活动", nil, SGHideLiveEvents),

            SGHideRow(@"探索艺人", nil, SGHideExploreArtist),

            SGHideRow(@"制作人员", nil, SGHideCredits),

            SGHideRow(@"周边商品", nil, SGHideMerch),

            SGHideRow(@"推荐内容", nil, SGHideRecommendations),

        ]),


        SGSection(@"隐藏播放器控件", @[

            SGHideRow(@"歌词预览", nil, SGHideLyricsInline),

            SGHideRow(@"随机播放", nil, SGHideShuffle),

            SGHideRow(@"重复播放", nil, SGHideRepeat),

            SGHideRow(@"添加到播放列表", nil, SGHideAddTo),

            SGHideRow(@"播放队列", nil, SGHideQueue),

            SGHideRow(@"分享", nil, SGHideShare),

            SGHideRow(@"连接设备", nil, SGHideConnect),

        ]),

    ];

}


SGModRow *SGGlassLyricsRow(void) {

    return SGOptionRow(@"玻璃效果歌词", nil, SGKeyLyricsCard);

}


UIViewController *SGQueueSettingsPage(void) {

    return [[SGModPage alloc] initWithTitle:@"播放队列与设备"
        intro:SGRestartNote
        sections:@[

        SGSection(@"底部弹层", @[

            SGFlagRow(@"播放队列使用底部弹层", @"ios-feature-nowplaying.bottom_sheet_queue_enabled"),

            SGFlagRow(@"设备连接使用底部弹层", @"ios-feature-nowplaying-elements.enable_connect_bottom_sheet"),

            SGFlagRow(@"从视频切换器打开设备连接弹层", @"ios-playbackcontrol-audiovideoswitcher-impl.enable_connect_bottom_sheet"),

        ]),


        SGSection(@"播放队列", @[

            SGFlagRow(@"队列翻转动画", @"ios-feature-nowplaying.queue_flip_transition_enabled"),

            SGFlagRow(@"上下文菜单显示“下一首播放”", @"ios-feature-queue.is_play_next_context_menu_enabled"),

        ]),

    ] footer:nil];

}
