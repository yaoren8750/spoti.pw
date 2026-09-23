#import "Core/SGCore.h"
#import "Settings/SGModPage.h"
#import "Album.h"

UIViewController *SGAlbumSettingsPage(void) {

    NSArray<SGModSection *> *sections = @[

        SGSection(@"顶部区域", @[

            SGOptionRow(@"封面背景", nil, SGKeyAlbumBackdrop),

        ]),


        SGSection(@"隐藏顶部区域内容", @[

            SGHideRow(@"探索（视频卡片）", nil, SGHideAlbumExplore),

            SGHideRow(@"添加到音乐库", nil, SGHideAlbumAddTo),

            SGHideRow(@"下载", nil, SGHideAlbumDownload),

            SGHideRow(@"更多选项", nil, SGHideAlbumMore),

        ]),


        SGNotedSection(@"隐藏页面内容", @[

            SGHideRow(@"艺人的更多作品", nil, SGHideAlbumMoreBy),

            SGHideRow(@"相关音乐视频", nil, SGHideAlbumVideos),

            SGHideRow(@"演唱会", nil, SGHideAlbumConcerts),

            SGHideRow(@"周边商品", nil, SGHideAlbumMerch),

            SGHideRow(@"你可能也喜欢", nil, SGHideAlbumYouMightLike),

        ], @"仅支持英文版 Spotify。"),

    ];


    return [[SGModPage alloc] initWithTitle:@"专辑"
        intro:nil
        sections:sections
        footer:nil];

}
