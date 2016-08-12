//
//  ViewController.m
//  Welcome2
//
//  Created by CMB on 16/8/10.
//  Copyright © 2016年 cmbchina. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UIImageView *keepImageView;

@property (weak, nonatomic) AVPlayer *player;
@property (strong,nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonToBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label1LeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label2LeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label3LeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label4LeadingConstraint;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initializeView];
    [self addObserverToPlayerItem:_player.currentItem];
    [self addObserverToNSNotificationCenter];
    
}
// 初始化
- (void)initializeView {
    // 通过文件URL来实例化AVPlayerItem
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"intro"
                                                       ofType:@"mp4"
                                                  inDirectory:@"videos"];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // 视频播放需要在AVPlayerLayer进行
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:playerLayer];
//    [_player play];
    
    // 设置按钮属性
    _registerBtn.layer.cornerRadius = 3.0f;
    [_registerBtn addTarget:self action:@selector(registerClick:) forControlEvents:UIControlEventTouchUpInside];
    _loginBtn.layer.cornerRadius = 3.0f;
    [_loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    _keepImageView.image = [UIImage imageNamed:@"keep"];
    
    [self setupTimer];
}
// 修改约束
- (void)updateViewConstraints {
    [super updateViewConstraints];
    CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
    _viewWidthConstraint.constant = windowFrame.size.width*4;
    _viewHeightConstraint.constant = windowFrame.size.height-_buttonHeightConstraint.constant-_buttonToBottomConstraint.constant;
    _labelWidthConstraint.constant = windowFrame.size.width;
    
    _label1LeadingConstraint.constant = 0;
    _label2LeadingConstraint.constant = windowFrame.size.width;
    _label3LeadingConstraint.constant = windowFrame.size.width*2;
    _label4LeadingConstraint.constant = windowFrame.size.width*3;
}


// 按钮事件
- (void)registerClick:(UIButton *)sender {
    NSLog(@"注册");
}
- (void)loginClick:(UIButton *)sender {
    NSLog(@"登录");
}
// scrollView委托方法,设置pageControl的当前页数
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
    _pageControl.currentPage = scrollView.contentOffset.x / windowFrame.size.width;
}
// pageControl事件
- (IBAction)changePage:(id)sender {
    [UIView animateWithDuration:0.1f animations:^{
        NSInteger cPage = _pageControl.currentPage;
        CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
        _scrollView.contentOffset = CGPointMake(cPage*windowFrame.size.width, 0.0f);
    }];
}

// 添加属性的观察者
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
}
/** * 观察者接收通知 *
 * @param keyPath 观察的属性
 * @param object 被观察者
 * @param 状态改变
 * @param context 上下文,这个是在注册观察者时设置的
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            NSLog(@"可以播放");
            [_player play];
        }
    }
    
}
// 移除属性的观察者
- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
}

// 通过NSNotificationCenter添加通知事件
- (void)addObserverToNSNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_player.currentItem];
}
- (void)playItemDidReachEnd:(NSNotification *)notif {
    [_player seekToTime:kCMTimeZero];
    [_player play];
}


// 设置定时器
- (void)setupTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
// 定时器事件
- (void)timerFireMethod {
    NSInteger nextPage = (_pageControl.currentPage+1)%4;
    CGRect windowFrame = [[[UIApplication sharedApplication] keyWindow] frame];
    [_scrollView setContentOffset:CGPointMake(nextPage*windowFrame.size.width, 0.0f) animated:YES];
}
# pragma mark - 内存警告通知
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_timer invalidate];
    [self removeObserverFromPlayerItem:_player.currentItem];
}
@end
