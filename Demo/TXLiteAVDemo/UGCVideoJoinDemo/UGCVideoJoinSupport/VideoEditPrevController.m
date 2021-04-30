//
//  TCVideoEditPrevController
//  TCLVBIMDemo
//
//  Created by annidyfeng on 2017/4/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "VideoEditPrevController.h"
#import "VideoPreviewViewController.h"
#import "MBProgressHUD.h"
#import "TXColor.h"
#import "UIView+Additions.h"
#import "VideoPreview.h"
#import "AppLocalized.h"
typedef  NS_ENUM(NSInteger,ActionType)
{
    ActionType_Save,
    ActionType_Publish,
    ActionType_Save_Publish,
};

@interface VideoEditPrevController ()<TXVideoGenerateListener,TXVideoJoinerListener,VideoPreviewDelegate>

@end

@implementation VideoEditPrevController {
    VideoPreview  *_videoPreview;
    TXVideoJoiner     *_ugcJoin;
    TXVideoEditer     *_ugcEdit;
    ActionType      _actionType;
    
    NSString        *_outFilePath;
    CGFloat         _currentPos;
    BOOL            _setPathSuccess;
    
    UILabel*        _generationTitleLabel;
    UIView*         _generationView;
    UIProgressView* _generateProgressView;
    UIButton*       _generateCannelBtn;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#if 0
    _outFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mp4"];
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _outFilePath = [documentsDirectory stringByAppendingPathComponent:@"output.mp4"];
#endif
    
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.back")
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = customBackButton;
    customBackButton.tintColor = TXColor.cyan;
    self.navigationItem.title = UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.videopreview");
    
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black"] forBarMetrics:UIBarMetricsDefault];
    
    
    _actionType = -1;
}

- (UIView*)generatingView
{
    /*用作生成时的提示浮层*/
    if (!_generationView) {
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        _generationView = [[UIView alloc] initWithFrame:window.bounds];
        
        _generationView.backgroundColor = UIColor.blackColor;
        _generationView.alpha = 0.9f;
        
        _generateProgressView = [UIProgressView new];
        _generateProgressView.center = CGPointMake(_generationView.width / 2, _generationView.height / 2);
        _generateProgressView.bounds = CGRectMake(0, 0, 225, 20);
        _generateProgressView.progressTintColor = TXColor.cyan;
        [_generateProgressView setTrackImage:[UIImage imageNamed:@"slide_bar_small"]];
        
        _generationTitleLabel = [UILabel new];
        _generationTitleLabel.font = [UIFont systemFontOfSize:14];
        _generationTitleLabel.text =  UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.videocompositing");
        _generationTitleLabel.textColor = UIColor.whiteColor;
        _generationTitleLabel.textAlignment = NSTextAlignmentCenter;
        _generationTitleLabel.frame = CGRectMake(0, _generateProgressView.y - 34, _generationView.width, 14);
        
        _generateCannelBtn = [UIButton new];
        [_generateCannelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        _generateCannelBtn.frame = CGRectMake(_generateProgressView.right + 15, _generationTitleLabel.bottom + 10, 20, 20);
        [_generateCannelBtn addTarget:self action:@selector(onGenerateCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_generationView addSubview:_generationTitleLabel];
        [_generationView addSubview:_generateProgressView];
        [_generationView addSubview:_generateCannelBtn];
        [window addSubview:_generationView];
    }
    
    _generateProgressView.progress = 0.f;
    return _generationView;
}

- (void)onGenerateCancelBtnClicked:(UIButton*)sender
{
    _generationView.hidden = YES;
    [_ugcJoin cancelJoin];
}

- (void)checkOutFilePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    if ([manager fileExistsAtPath:_outFilePath]) {
        BOOL success = [manager removeItemAtPath:_outFilePath error:&error];
        if (success) {
            NSLog(@"Already exist. Removed!");
        }
    }
    
}

- (void)goBack
{
    [self onVideoPause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _videoPreview = [[VideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.prevPlaceHolder.width, self.prevPlaceHolder.height) coverImage:[TXVideoInfoReader getVideoInfoWithAsset:_composeArray.firstObject].coverImage];
    _videoPreview.delegate = self;
    [self.prevPlaceHolder addSubview:_videoPreview];
    
    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _videoPreview.renderView;
    param.renderMode = PREVIEW_RENDER_MODE_FILL_EDGE;
    _ugcJoin = [[TXVideoJoiner alloc] initWithPreview:param];
    int reslut = [_ugcJoin setVideoAssetList:_composeArray];
    if (reslut != 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.getvideoerror") message: UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.videolistnothave") delegate:self cancelButtonTitle:UGCLocalize(@"UGCVideoRecordDemo.VideoRecordConfig.knowed") otherButtonTitles:nil, nil];
        [alertView show];
        _setPathSuccess = NO;
    }else{
        _setPathSuccess = YES;
    }
    _ugcJoin.previewDelegate = _videoPreview;
    _ugcJoin.joinerDelegate = self;
    [self play];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_ugcJoin pausePlay];
}

- (void)play{
    [_ugcJoin startPlay];
    [_videoPreview setPlayBtn:YES];
}


#pragma mark VideoPreviewDelegate
- (void)onVideoPlay
{
    if (_ugcJoin) {
        [_ugcJoin startPlay];
    }else{
        
    }
}

- (void)onVideoPause
{
    if (_ugcJoin) {
        [_ugcJoin pausePlay];
    }else{
        
    }
}

- (void)onVideoResume
{
    if (_ugcJoin) {
        [_ugcJoin resumePlay];
    } else {
        
    }
}

- (void)onVideoPlayProgress:(CGFloat)time
{
    _currentPos = time;
    
}

- (void)onVideoPlayFinished
{
    [_ugcJoin startPlay];
}

- (void)onVideoEnterBackground
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self onVideoPause];
    if (_generationView && !_generationView.hidden) {
        _generationView.hidden = YES;
        [_ugcJoin cancelJoin];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.videocompositingerror")
                                                            message:UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.backgrounderror")
                                                           delegate:self
                                                  cancelButtonTitle:UGCLocalize(@"UGCVideoRecordDemo.VideoRecordConfig.knowed")
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)onJoinComplete:(TXJoinerResult *)result
{
    _generationView.hidden = YES;
    if(result.retCode == 0)
    {
        TXVideoInfo *videoInfo = [TXVideoInfoReader getVideoInfo:_outFilePath];
        VideoPreviewViewController* vc = [[VideoPreviewViewController alloc] initWithCoverImage:videoInfo.coverImage videoPath:_outFilePath renderMode:RENDER_MODE_FILL_EDGE showEditButton:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.videocompositingerror")
                                                            message:
                                  LocalizeReplace(UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.errorcodexxerrormsgyy"), [NSString stringWithFormat:@"%ld",(long)result.retCode], [NSString stringWithFormat:@"%@",result.descMsg])
                                                           delegate:self
                                                  cancelButtonTitle:UGCLocalize(@"UGCVideoRecordDemo.VideoRecordConfig.knowed")
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void) onJoinProgress:(float)progress {
    _generateProgressView.progress = progress;
}

- (IBAction)saveAndPublish:(id)sender {
    _actionType = ActionType_Save;
    [self process];
}


- (void)process {
    [_videoPreview setPlayBtn:NO];
    [self onVideoPause];
    [self checkOutFilePath];
    
    if (_ugcJoin) {
        if (!_setPathSuccess) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.getvideoerror") message:UGCLocalize(@"UGCVideoJoinDemo.TCVideoEditPrev.videolistnothave") delegate:self cancelButtonTitle:UGCLocalize(@"UGCVideoRecordDemo.VideoRecordConfig.knowed") otherButtonTitles:nil];
            [alertView show];
            return;
        }
        [_ugcJoin joinVideo:VIDEO_COMPRESSED_540P videoOutputPath:_outFilePath];
    }
    
    // Set the bar determinate mode to show task progress.
    _generationView = [self generatingView];
    _generationView.hidden = NO;
}
@end
