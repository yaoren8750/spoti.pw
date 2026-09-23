#import "Settings/SGModPage.h"
#import "Playlist.h"

UIViewController *SGPlaylistSettingsPage(void) {

    return [[SGModPage alloc] initWithTitle:@"播放列表"
        intro:nil
        sections:@[

        SGSection(@"顶部区域", @[

            SGOptionRow(@"封面背景", nil, SGKeyPlaylistBackdrop),

        ]),


        SGSection(@"隐藏播放列表顶部区域", @[

            SGHideRow(@"封面图片", nil, SGHidePlaylistArtwork),

            SGHideRow(@"描述", nil, SGHidePlaylistDescription),

            SGHideRow(@"创建者和协作者", nil, SGHidePlaylistCreator),

            SGHideRow(@"时长和收藏数", nil, SGHidePlaylistLength),

        ]),


        SGSection(@"隐藏播放列表按钮", @[

            SGHideRow(@"视频", nil, SGHidePlaylistVideo),

            SGHideRow(@"添加到音乐库", nil, SGHidePlaylistAddTo),

            SGHideRow(@"下载", nil, SGHidePlaylistDownload),

            SGHideRow(@"分享", nil, SGHidePlaylistShare),

            SGHideRow(@"更多", nil, SGHidePlaylistMore),

        ]),


        SGSection(@"隐藏歌曲列表上方内容", @[

            SGHideRow(@"分类标签", nil, SGHidePlaylistPills),

            SGHideRow(@"查找和排序栏", nil, SGHidePlaylistFind),

        ]),

    ] footer:nil];

}
