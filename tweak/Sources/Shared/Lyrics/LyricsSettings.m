// The Lyrics page's parts; App/Pages.m assembles the page.
#import "Core/SGCore.h"
#import "Settings/SGModPage.h"
#import "Lyrics.h"
#import "Shared/LockScreenLyrics/LockScreenLyrics.h"
#import "Shared/LyricsSources/LyricsSources.h"

SGModSection *SGLyricsSourcesSection(BOOL namingSource) {

    SGModRow *sources = SGPageRow(@"来源", ^UIViewController *{ return SGLyricsSourcesPage(); });

    sources.value = ^NSString *{

        NSMutableArray<NSString *> *names = [NSMutableArray array];

        for (NSString *key in SGLyricsOrder()) [names addObject:SGLyricsProviderFor(key).name];

        return names.count ? [names componentsJoinedByString:@", "] : @"关闭";

    };

    NSMutableArray<SGModRow *> *rows = [NSMutableArray arrayWithObjects:sources,

        SGOptionRow(@"每首歌曲显示歌词", @"即使 Spotify 没有提供歌词", SGKeyLyricsAllTracks), nil];

    if (namingSource) [rows addObject:SGOptionRow(@"显示来源", nil, SGKeyLyricsCredit)];

    return SGSection(@"来源", rows);

}

SGModRow *SGLockScreenLyricsRow(void) {

    return SGOptionRow(@"锁屏歌词", @"用当前歌词替代艺人信息", SGKeyLockScreenLyrics);

}

SGModRow *SGLyricsTranslationLanguageRow(void) {

    SGModRow *row = SGChoiceRow(@"翻译语言", nil, SGKeyLyricsTranslationLanguage, SGLyricsTranslationLanguageNames(), 0);

    row.choiceFooter = @"用于歌词包含翻译的情况。选择“任意”将显示第一个可用翻译。";

    return row;

}

// Only the redesign's lyrics view sweeps words.

SGModRow *SGLyricsWordTimingRow(void) {

    return SGOptionRow(@"模拟逐词时间", nil, SGKeyLyricsSimulateWords);

}
