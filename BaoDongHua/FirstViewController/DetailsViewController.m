//
//  DetailsViewController.m
//  BaoDongHua
//
//  Created by shen on 17/2/5.
//  Copyright © 2017年 shen. All rights reserved.
//

#import "DetailsViewController.h"
#import "VideosModel.h"
#import "BaoHistoryManger.h"
#import "VideoViewController.h"

@import GoogleMobileAds;

static NSString *const AdUnitId = @"ca-app-pub-4903381575382292/4345741960";

@interface DetailsViewController ()<GADNativeExpressAdViewDelegate, GADVideoControllerDelegate>{
    
    GADNativeExpressAdView *_nativeExpressAdView;
    
    UIScrollView *_scrollView;
    NSMutableArray *_selecBtnArr;
    VideosModel *_model;
    UIButton *_selectButton;
    NSInteger _indexTag;
    
    CGFloat _width;
    CGFloat _height;

}
@property (strong,nonatomic)UIButton *selectButton;
@property (nonatomic, assign) CGRect videoViewFrame;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (kScreenWidth > kScreenHeight) {
        _width = kScreenHeight;
        _height = kScreenWidth;
        
    }else{
        _height = kScreenHeight;
        _width = kScreenWidth;
    }
    
    
    
    self.title = @"视频详情";
    
    _selecBtnArr = [NSMutableArray array];

    [self createTopView];
    [self createGADNativeExpressAdView];
    [self getVideosPlayerData];
    
}
-(void)getVideosPlayerData{
    
    NSString *urlstr = [NSString stringWithFormat:@"%@v_id=%@",Detailurl,_v_id];
    [[AFNetworkingManager manager] getDataWithUrl:urlstr parameters:nil successBlock:^(id data) {
//                NSLog(@"---------%@",data);
        for (NSDictionary *dic in data[@"data"]) {
            
            _model = [[VideosModel alloc]init];
            [_model setValuesForKeysWithDictionary:dic];
            
            for (NSDictionary *playDic in dic[@"playbody"]) {
                
                for (NSDictionary *play in playDic[@"playinfo"]) {
                    
                    [_selecBtnArr addObject:play];
                }
            }
        }
        
        [self createSelecteView];
        
        [[BaoHistoryManger shareManager] insertDataWithModel:_model];
        
    } failureBlock:^(NSString *error) {
        NSLog(@"---------------%@",error);
    }];
    
}
-(void)createSelecteView{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_nativeExpressAdView.frame), _width, _height - _nativeExpressAdView.height - 64)];
    _scrollView.scrollEnabled = YES;
    _scrollView.backgroundColor = ViewBackgroundColor;
    _scrollView.contentSize = CGSizeMake(0, _height);
    [self.view addSubview:_scrollView];
    
    
    UIView *introductionView = [BaoDongHuaTool createViewWithFrame:CGRectMake(0,0 , _width, 100)];
    introductionView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:introductionView];
    
    UIImageView *videosPicView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    [videosPicView sd_setImageWithURL:[NSURL URLWithString:_model.v_pic] placeholderImage:nil];
    [introductionView addSubview:videosPicView];
    
    UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(videosPicView.frame) + 10, 0, _width - CGRectGetMaxX(videosPicView.frame) -10  ,90)];
    contentView.font = [UIFont systemFontOfSize:14];
    contentView.text = [NSString stringWithFormat:@"剧情简介:%@",_model.content];
    contentView.editable = NO;
    [introductionView addSubview:contentView];
    
    UIView *selectionsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(introductionView.frame) + 10, _width,400)];
    selectionsView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:selectionsView];
    
    UILabel *selectionsLB = [BaoDongHuaTool createLabelWithFrame:CGRectMake(10, 0 , _width, 30) Font:16 Text:@"选集"];
    [selectionsView addSubview:selectionsLB];
    
    CGSize sizeBtn = CGSizeMake((selectionsView.width - 60)/5,50);
    for (int i = 0; i < _selecBtnArr.count; i ++ ) {
        CGFloat x = self.videoViewFrame.origin.x;
        CGFloat y = self.videoViewFrame.origin.y;
        if (i != 0) {
            x += sizeBtn.width;
        }else {
            y += CGRectGetMaxY(selectionsLB.frame) + 10;
        }
        CGFloat minX = x;
        CGFloat maxX = x + sizeBtn.width;
        if (maxX > CGRectGetWidth(selectionsView.frame)) {
            x -= minX;
            y = y + sizeBtn.height + 10;
        }
        CGRect rect = CGRectMake(x + 10, y, sizeBtn.width, sizeBtn.height);
        self.videoViewFrame = rect;
        UIButton *selections = [BaoDongHuaTool createButtonWithFrame:rect backGruondImageName:@"" Target:self Action:@selector(buttonClick:) Title:[NSString stringWithFormat:@"%d",i + 1]];
        selections.tag = i + 1000;
        selections.layer.cornerRadius = 10.0;
        selections.backgroundColor = SelectButtonColor;
        [selectionsView addSubview:selections];
    }
    
    CGFloat H;
    if (_selecBtnArr.count%5==0) {
        H = ( sizeBtn.height + 10) * (_selecBtnArr.count/5);
    }else{
        H = ( sizeBtn.height + 10) * (_selecBtnArr.count/5 + 1);
    }
    selectionsView.frame = CGRectMake(0, CGRectGetMaxY(introductionView.frame) + 10, _width,H  + CGRectGetMaxY(selectionsLB.frame) + 10);
    
    _scrollView.contentSize = CGSizeMake(0,CGRectGetMaxY(selectionsView.frame) + 10);
    
}

-(void)buttonClick:(UIButton *)button{
    
    _indexTag = button.tag - 1000 ;
    
    VideoViewController *videosVC = [[VideoViewController alloc] init];
    videosVC.v_id = _v_id;
    videosVC.videoIndexTag = [NSString stringWithFormat:@"%ld",(long)_indexTag];
    [self presentViewController:videosVC animated:NO completion:nil];
    
    
}

-(void)createGADNativeExpressAdView{
    
    CGPoint origin = CGPointMake(0, 64);
    _nativeExpressAdView = [[GADNativeExpressAdView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(_width, 250)) origin:origin];
    [self.view addSubview:_nativeExpressAdView];
    
    _nativeExpressAdView.adUnitID = AdMob_NativeExpressAdUnitID;
    _nativeExpressAdView.rootViewController = self;
    _nativeExpressAdView.delegate = self;
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = true;
    [_nativeExpressAdView setAdOptions:@[ videoOptions ]];
    _nativeExpressAdView.videoController.delegate = self;
    
    GADRequest *request = [GADRequest request];
    [_nativeExpressAdView loadRequest:request];
}
-(void)createTopView{
    
    UIImageView *imageView = [BaoDongHuaTool createImageViewWithFrame:CGRectMake(0, 20,_width, 44) ImageName:@"topbg.png"];
    
    UIButton *backBtn = [BaoDongHuaTool createButtonWithFrame:CGRectMake(20, 5, 35, 35) backGruondImageName:@"player-back" Target:self Action:@selector(clilkBackBtn) Title:nil];
    [imageView addSubview:backBtn];
    [self.view addSubview:imageView];
}
-(void)clilkBackBtn{
    
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GADNativeExpressAdViewDelegate

- (void)nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView *)nativeExpressAdView {
    if (nativeExpressAdView.videoController.hasVideoContent) {
        NSLog(@"Received ad an with a video asset.");
    } else {
        NSLog(@"Received ad an without a video asset.");
    }
}

#pragma mark - GADVideoControllerDelegate

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
    NSLog(@"Playback has ended for this ad's video asset.");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
