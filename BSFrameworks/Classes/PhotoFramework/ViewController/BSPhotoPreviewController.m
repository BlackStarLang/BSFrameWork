//
//  BSPhotoPreviewController.m
//  BSFrameworks
//
//  Created by 叶一枫 on 2020/3/30.
//

#import "BSPhotoPreviewController.h"
#import "PhotoPreviewCell.h"
#import "BSPhotoModel.h"
#import "BSPhotoViewModel.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface BSPhotoPreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic ,strong) UICollectionView *collectionView;


@end

@implementation BSPhotoPreviewController


-(void)dealloc{
    NSLog(@"==== %@ dealloc =====",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
    [self masonryLayout];
    // Do any additional setup after loading the view.
}

-(void)initSubViews{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}


-(void)masonryLayout{
    
    
//    self.collectionView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);

    [self.collectionView setNeedsLayout];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
}


#pragma mark - set method

-(void)setPreviewPhotos:(NSArray *)previewPhotos previewType:(PREVIEWTYPE)previewType defaultIndex:(NSInteger)defaultIndex{
    
    _previewPhotos = [NSMutableArray arrayWithArray:previewPhotos];
    _previewType = previewType;
    _currentIndex = defaultIndex;

}




#pragma mark - UICollectionView delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.previewPhotos.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;

    return CGSizeMake(width, height);
}


-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoPreviewCell" forIndexPath:indexPath];
    
    if (self.previewType == PREVIEWTYPE_URL) {
        
        NSString *url = self.previewPhotos[indexPath.row];
        NSURL *URL = [NSURL URLWithString:url];
        [cell.imageView sd_setImageWithURL:URL placeholderImage:nil];
        
    }else if (self.previewType == PREVIEWTYPE_PATH){
        
        NSString *path = self.previewPhotos[indexPath.row];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        cell.imageView.image = image;
        
    }else if (self.previewType == PREVIEWTYPE_IMAGE){
        
        UIImage *image = self.previewPhotos[indexPath.row];
        cell.imageView.image = image;
        
    }else if (self.previewType == PREVIEWTYPE_PHOTO){
        BSPhotoModel *model = self.previewPhotos[indexPath.row];
        cell.imageView.image = model.thumbImage;
    }
    
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.view.backgroundColor = [UIColor whiteColor];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.view.backgroundColor = [UIColor blackColor];
        self.collectionView.backgroundColor = [UIColor blackColor];
    }
}

#pragma mark - systemDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
}



#pragma mark - init 属性初始化

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(25, 0, 25, 0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[PhotoPreviewCell class] forCellWithReuseIdentifier:@"PhotoPreviewCell"];
    }
    return _collectionView;
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
