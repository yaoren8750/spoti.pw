// Labs: Spotify's flags for features it built and did not ship; every row forces one flag.
#import "Settings/SGModPage.h"
#import "Flags.h"

static UIViewController *martiniPage(void) {
    return [[SGModPage alloc] initWithTitle:@"AI Chat (Martini)" intro:SGRestartNote sections:@[
        SGSection(@"首页", @[
            SGFlagRow(@"聊天入口", @"ios-home-evopage-impl.interactive_entrypoint_enabled"),
            SGFlagRow(@"启用 Martini 后端", @"ios-home-evopage-impl.interactive_entrypoint_martini_enabled"),
            SGFlagRow(@"浮动聊天", @"ios-home-evopage-impl.interactive_entrypoint_floating_chat_enabled"),
            SGFlagRow(@"麦克风", @"ios-home-evopage-impl.interactive_entrypoint_mic_enabled"),
            SGFlagRow(@"发光胶囊", @"ios-home-evopage-impl.interactive_entrypoint_pill_glow_enabled"),
        ]),
        SGSection(@"聊天功能", @[
            SGFlagRow(@"意图快捷选项", @"ios-martini-floatingchat-impl.intent_pills_enabled"),
            SGFlagRow(@"思考状态", @"ios-martini-floatingchat-impl.thinking_states_enabled"),
            SGFlagRow(@"语音录制", @"ios-martini-floatingchat-impl.voice_recording_enabled"),
        ]),
        SGSection(@"播放器中", @[
            SGFlagRow(@"聊天入口", @"ios-martini-npvcardprovider-impl.floating_chat_entry_point_enabled"),
        ]),
    ] footer:nil];
}

UIViewController *SGLabsPage(void) {
    return [[SGModPage alloc] initWithTitle:@"实验室" intro:@"未发布功能；部分功能可能无法在你的版本中使用。更改将在重启 Spotify 后生效。" sections:@[
        SGSection(nil, @[
            SGWithSymbol(SGPageRow(@"AI Chat (Martini)", ^UIViewController *{ return martiniPage(); }), @"bubble.left.and.bubble.right"),
        ]),
        SGSection(@"音乐库", @[
            SGFlagRow(@"从文件 App 添加本地文件", @"ios-feature-localfiles.documents_enabled"),
        ]),
        SGSection(@"主屏幕小组件", @[
            SGFlagRow(@"进度条", @"ios-widgets-widgetremoteconfig-impl.progress_bar_enabled"),
        ]),
        SGNotedSection(@"睡眠定时器", @[
            SGFlagRow(@"淡出效果", @"ios-feature-sleeptimer.enable_fade_out"),
            SGFlagRow(@"一分钟选项", @"ios-feature-sleeptimer.enable_one_minute_option"),
            SGFlagRow(@"选项面板", @"ios-feature-sleeptimer.use_options_sheet"),
        ], @"在重新设计界面中，选项面板始终开启。"),
        SGSection(@"播放器", @[
            SGFlagRow(@"封面上的贪吃蛇动画", @"ios-feature-cover-art-snake.enabled"),
        ]),
        SGSection(@"播客评论", @[
            SGFlagRow(@"评论卡片", @"ios-feature-comments.enable_comments_card"),
            SGFlagRow(@"置顶评论", @"ios-feature-comments.enable_pinned_comments"),
            SGFlagRow(@"多种表情回应", @"ios-feature-comments.enable_multi_reactions"),
        ]),
    ] footer:nil];
}
