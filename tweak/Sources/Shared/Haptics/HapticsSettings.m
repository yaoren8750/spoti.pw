// The Vibrations sections of the Player page, under either look (App/Pages.m puts them there): a card
// per switch, the way the Audio effects page has one per effect, each opening out into its settings while
// its switch is on. Controls has its strength; Music Haptics its strength and what it follows, a choice
// that also says whether the rumble plays, rather than a switch of its own that one choice would leave
// with nothing to do.
#import "Core/SGCore.h"
#import "Settings/SGModPage.h"
#import "Haptics.h"

static NSString *const kMusicHapticsInfo = @"iPhone 会根据 Spotify 正在播放的音乐节奏产生触感反馈：鼓点时轻触，低音时震动。它会根据播放中的声音实时分析，类似 Apple Music 中的音乐触感功能。\n\n"
@"它跟随此 iPhone 当前播放的声音，无论来自扬声器还是耳机。Spotify 在后台运行时，iOS 不会为应用播放触感反馈；通过 Connect 在其他设备播放的歌曲，也不会有可供此设备跟随的声音。";

static NSArray<NSString *> *followsNames(void) {
    return @[@"全部", @"节拍", @"低音"];
}

static NSArray<NSString *> *followsNotes(void) {
    return @[@"每次底鼓和军鼓都会触发震动，并在低音部分提供震感",
             @"每次底鼓和军鼓都会触发震动，不包含低音震感",
             @"每次底鼓都会触发震动，并在低音部分提供震感"];
}

static void strengthRange(NSString *key, NSInteger *minimum, NSInteger *maximum) {
    BOOL music = [key isEqualToString:SGKeyMusicStrength];
    *minimum = music ? SGMusicStrengthMin : SGControlStrengthMin;
    *maximum = music ? SGMusicStrengthMax : SGControlStrengthMax;
}

double SGHapticsStrength(NSString *key) {
    NSInteger minimum, maximum;
    strengthRange(key, &minimum, &maximum);
    return MAX(minimum, MIN(maximum, SGInt(key, 100))) / 100.0;
}

SGMusicFollows SGMusicHapticsFollows(void) {
    NSInteger follows = SGInt(SGKeyMusicFollows, SGMusicFollowsEverything);
    return follows >= SGMusicFollowsEverything && follows <= SGMusicFollowsBass ? (SGMusicFollows)follows : SGMusicFollowsEverything;
}

// A percentage slider over a strength key, telling `changed` each step it stores.
static SGModRow *strengthRow(NSString *key, void (^changed)(void)) {
    NSInteger minimum, maximum;
    strengthRange(key, &minimum, &maximum);
    return SGSliderRow(@"强度", nil, minimum, maximum, SGStrengthStep,
        ^double { return SGHapticsStrength(key) * 100; },
        ^(double value) {
            SGSetInt(key, lround(value));
            if (changed) changed();
        },
        ^NSString *(double value) { return [NSString stringWithFormat:@"%ld%%", lround(value)]; });
}

NSArray<SGModSection *> *SGVibrationsSections(void) {
    SGModRow *controls = SGSwitchRow(@"控制", nil, SGKeyControlHaptics);
    SGModRow *controlStrength = strengthRow(SGKeyControlStrength, ^{
        // Felt as it is set: a tap at the new strength with each step.
        SGPlayFeedback(SGFeedbackAdd);
    });
    controlStrength.visible = ^BOOL { return SGEnabled(SGKeyControlHaptics); };

    SGModRow *music = SGOptionRow(@"音乐触感", nil, SGKeyMusicHaptics);
    music.info = kMusicHapticsInfo;
    music.changed = ^(BOOL on) { SGSetMusicHapticsEnabled(on); };
    BOOL (^musicOn)(void) = ^BOOL { return SGFlag(SGKeyMusicHaptics, NO); };
    SGModRow *musicStrength = strengthRow(SGKeyMusicStrength, ^{ SGMusicHapticsSettingsChanged(); });
    musicStrength.visible = musicOn;
    SGModRow *follows = SGChoiceRow(@"触觉跟随", nil, SGKeyMusicFollows, followsNames(), SGMusicFollowsEverything);
    follows.choiceNotes = followsNotes();
    follows.chosen = ^(NSInteger index) { SGMusicHapticsSettingsChanged(); };
    follows.visible = musicOn;

    return @[
        SGSection(@"触感反馈", @[SGWithSymbol(controls, @"hand.tap"), controlStrength]),
        SGSection(nil, @[SGWithSymbol(music, @"waveform"), musicStrength, follows]),
    ];
}
