#import "Core/SGCore.h"
#import "Settings/SGModPage.h"
#import "Home.h"
#import "Native/Playlist/Playlist.h"
#import "Native/Artist/Artist.h"
#import "Native/Album/Album.h"

static SGModRow *choiceRow(NSString *title, NSString *subtitle, SGHomeChoice choice) {
    return SGChoiceRow(title, subtitle, SGHomeChoiceKey(choice), SGHomeChoiceNames(choice),
                       SGHomeChoiceDefault(choice));
}

UIViewController *SGHomeGradientPage(void) {
    return [[SGModPage alloc] initWithTitle:@"渐变"
                                      intro:@"开启或关闭后，需要重启 Spotify 才会生效。"
                                   sections:@[
        SGSection(@"渐变", @[
            SGOptionRow(@"显示", nil, SGKeyHomeGradient),
            choiceRow(@"颜色", nil, SGHomeChoiceTint),
            choiceRow(@"强度", nil, SGHomeChoiceStrength),
            choiceRow(@"高度", nil, SGHomeChoiceHeight),
        ]),
    ] footer:nil];
}

static UIViewController *libraryPage(void) {
    return [[SGModPage alloc] initWithTitle:@"媒体库" intro:nil sections:@[
        SGSection(@"媒体库", @[
            SGFlagRow(@"更紧凑的列表", @"ios-feature-yourlibaryx.denser_rows_enabled"),
            SGFlagRow(@"按最近更新排序播放列表", @"ios-feature-yourlibaryx.recently_updated_playlists_sort_enabled"),
            SGFlagRow(@"按最近更新排序艺人", @"ios-feature-yourlibaryx.recently_updated_artists_sort_enabled"),
            SGFlagRow(@"最近播放", @"ios-feature-yourlibaryx.recents_enabled"),
            SGFlagRow(@"最近播放排序方式", @"ios-feature-yourlibaryx.recents_sort_order_enabled"),
            SGFlagRow(@"媒体库设置", @"ios-feature-yourlibaryx.library_settings_enabled"),
            SGFlagRow(@"媒体库 Pro", @"ios-feature-yourlibaryx.your_library_pro_enabled"),
        ]),
    ] footer:nil];
}

UIViewController *SGHomeSettingsPage(void) {
    // The row reads its own state out, so the section says which colour is set without being opened.
    SGModRow *gradient = SGPageRow(@"渐变", ^UIViewController *{ return SGHomeGradientPage(); });
    gradient.value = ^NSString *{
        if (!SGFlag(SGKeyHomeGradient, NO)) return @"关闭";
        return SGHomeChoiceNames(SGHomeChoiceTint)[(NSUInteger)SGHomeChoiceValue(SGHomeChoiceTint)];
    };

    NSArray<SGModSection *> *sections = @[
        SGSection(nil, @[
            SGWithSymbol(SGPageRow(@"播放列表", ^UIViewController *{ return SGPlaylistSettingsPage(); }), @"music.note.list"),
            SGWithSymbol(SGPageRow(@"媒体库", ^UIViewController *{ return libraryPage(); }), @"books.vertical"),
            SGWithSymbol(SGPageRow(@"专辑", ^UIViewController *{ return SGAlbumSettingsPage(); }), @"square.stack"),
            SGWithSymbol(SGPageRow(@"艺人", ^UIViewController *{ return SGArtistSettingsPage(); }), @"music.mic"),
        ]),
        SGSection(@"主页", @[
            SGWithSymbol(gradient, @"rectangle.tophalf.inset.filled"),
            SGFlagRow(@"下拉刷新", @"ios-home-evopage-impl.pull_to_refresh_enabled"),
        ]),
        SGSection(@"主页隐藏项目", @[
            SGHideRow(@"筛选标签", nil, SGHideHomePills),
            SGHideRow(@"快捷入口网格", nil, SGHideHomeShortcuts),
            SGHideRow(@"推广卡片", nil, SGHideHomePromo),
            SGHideRow(@"预览卡片", nil, SGHideHomePreviews),
            SGHideRow(@"DJ 卡片", nil, SGHideHomeDJ),
            SGKillRow(@"DJ 按钮", @"ios-home-evopage-impl.idj_show_dj_button"),
            SGKillRow(@"DJ beta 标识", @"ios-home-evopage-impl.dj_mdc_beta_badge_enabled"),
        ]),
    ];
    return [[SGModPage alloc] initWithTitle:@"主页&媒体库" intro:nil sections:sections footer:nil];
}
