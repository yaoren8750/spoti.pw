#import "Core/SGCore.h"
#import "Settings/SGModPage.h"
#import "Artist.h"

UIViewController *SGArtistSettingsPage(void) {
    NSArray<SGModSection *> *sections = @[
        SGSection(@"照片", @[
            SGOptionRow(@"渐变模糊", nil, SGKeyArtistPhotoFade),
        ]),
        SGSection(@"隐藏顶部区域", @[
            SGHideRow(@"探索（视频卡片）", nil, SGHideArtistExplore),
            SGHideRow(@"关注", nil, SGHideArtistFollow),
            SGHideRow(@"更多选项", nil, SGHideArtistMore),
            SGHideRow(@"随机播放", nil, SGHideArtistShuffle),
            SGHideRow(@"认证标识", nil, SGHideArtistVerified),
            SGHideRow(@"月 听众数", nil, SGHideArtistListeners),
        ]),
        SGSection(@"标签页", @[
            SGHideRow(@"隐藏标签栏", nil, SGHideArtistTabBar),
        ]),
        SGNotedSection(@"隐藏页面内容", @[
            SGHideRow(@"喜欢的歌曲", nil, SGHideArtistLikedSongs),
            SGHideRow(@"热门歌曲", nil, SGHideArtistPopular),
            SGHideRow(@"艺人精选", nil, SGHideArtistPick),
            SGHideRow(@"热门发行作品", nil, SGHideArtistReleases),
            SGHideRow(@"参与合作", nil, SGHideArtistFeaturing),
            SGHideRow(@"音乐视频", nil, SGHideArtistVideos),
            SGHideRow(@"关于", nil, SGHideArtistAbout),
            SGHideRow(@"艺人歌单", nil, SGHideArtistPlaylists),
            SGHideRow(@"粉丝也喜欢", nil, SGHideArtistFansAlsoLike),
            SGHideRow(@"参与的作品", nil, SGHideArtistAppearsOn),
            SGHideRow(@"发现来源", nil, SGHideArtistDiscoveredOn),
        ], @"仅支持英文版 Spotify。"),
        SGSection(@"Spotify 原生功能", @[
            SGFlagRow(@"顶部分享按钮", @"ios-creator-impl.share_in_action_row_enabled_artist"),
            SGFlagRow(@"导航栏中的更多选项", @"ios-creator-impl.context_menu_in_navigation_bar_enabled_artist"),
            SGFlagRow(@"主要合作艺人", @"ios-creator-impl.is_top_collaborators_enabled"),
            SGFlagRow(@"艺人信息", @"ios-creator-impl.is_artist_facts_enabled"),
        ]),
    ];
    return [[SGModPage alloc] initWithTitle:@"艺人" intro:nil sections:sections footer:nil];
}
