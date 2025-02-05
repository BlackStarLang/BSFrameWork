//
//  BSPhotoDataManager.m
//  BSFrameworks
//
//  Created by 叶一枫 on 2020/3/28.
//

#import "BSPhotoDataManager.h"

#import "BSPhotoGroupModel.h"
#import "BSPhotoModel.h"

@interface BSPhotoDataManager ()

@property (nonatomic ,strong) PHImageManager *manager;

@property (nonatomic ,strong) PHCachingImageManager *cacheManager;
@property (nonatomic ,strong) PHImageRequestOptions *options;

@end


@implementation BSPhotoDataManager

-(void)stopAllCache{
    
    [self.cacheManager stopCachingImagesForAllAssets];
}



#pragma mark - 相册资源获取

///MARK: 获取相机胶卷相册的 所有照片对象
-(void)getPhotoLibraryGroupModel:(void(^)(BSPhotoGroupModel *groupModel))groupModel{

    ///获取 智能相册-sub普通相册 的所有照片
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    for (PHAssetCollection *collection in result) {
        
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            
            BSPhotoGroupModel *model = [[BSPhotoGroupModel alloc]init];
            ///相册名称
            model.title = [model getTitleNameWithCollectionLocalizedTitle:collection.localizedTitle];
            ///相册资源合计
            model.assetCollection = collection;
            groupModel(model);
            break;
        }
    }
}

///获取所有相册对象
-(void)getAllAlbumsWithType:(LibraryType)libraryType albums:(void(^)(NSArray *albums))albums{

    PHFetchResult *smartResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *userResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    if (libraryType == 0) {
        options.predicate =  [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    }else if (libraryType == 1){
        options.predicate =  [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeVideo];
    }else{
        
    }
    
    
    NSMutableArray *mutArr = [NSMutableArray array];
    
    ///智能相册
    for (PHAssetCollection *assetCollection in smartResult) {

        PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        NSInteger count = 0;
        if (libraryType == 0) {
            count = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        }else if (libraryType == 1){
            count = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        }else{
            NSInteger imgCount = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
            NSInteger videoCount = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
            count = imgCount + videoCount;
        }
        
        if (count && ![assetCollection.localizedTitle isEqualToString:@"Recently Deleted"]) {
            BSPhotoGroupModel *model = [[BSPhotoGroupModel alloc]init];
            [mutArr addObject:model];
            
            model.fetchResult = assetResult;
            model.assetCollection = assetCollection;
            model.count = count;
            model.title = [model getTitleNameWithCollectionLocalizedTitle:assetCollection.localizedTitle];
        }
    }
    
    
    ///用户相册
    for (PHAssetCollection *assetCollection in userResult) {

        PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        NSInteger count = 0;
        if (libraryType == 0) {
            count = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        }else if (libraryType == 1){
            count = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        }else{
            NSInteger imgCount = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
            NSInteger videoCount = [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
            count = imgCount + videoCount;
        }
        
        if (count && ![assetCollection.localizedTitle isEqualToString:@"Recently Deleted"]) {
            BSPhotoGroupModel *model = [[BSPhotoGroupModel alloc]init];
            [mutArr addObject:model];
            
            model.fetchResult = assetResult;
            model.assetCollection = assetCollection;
            model.count = count;
            model.title = [model getTitleNameWithCollectionLocalizedTitle:assetCollection.localizedTitle];
        }
    }
    
    albums(mutArr);
}


/// 预加载缓存 图片
/// assetCollection 要加载的相册
/// targetSize 缓存图片大小
/// contenModel 图片预显示模式
-(void)startPreLoadCacheImagesWithPHAssetArray:(NSArray *)assetArray targetSize:(CGSize)targetSize contenModel:(PHImageContentMode)contentMode{

    [self.cacheManager startCachingImagesForAssets:assetArray targetSize:targetSize contentMode:contentMode options:self.options];
}


/// 停止预加载缓存 图片
/// assetCollection 要加载的相册
/// targetSize 缓存图片大小
/// contenModel 图片预显示模式
-(void)stopPreLoadCacheImagesWithPHAssetArray:(NSArray *)assetArray targetSize:(CGSize)targetSize contenModel:(PHImageContentMode)contentMode{
    
    [self.cacheManager stopCachingImagesForAssets:assetArray targetSize:targetSize contentMode:contentMode options:self.options];
}


/// 根据 PHAsset 获取图片
-(void)getImageWithPHAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentModel:(PHImageContentMode )contentModel imageBlock:(void(^)(UIImage *targetImage))imageBlock{
    
    [self.cacheManager requestImageForAsset:asset targetSize:targetSize contentMode:contentModel options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

        imageBlock(result);
    }];
}


/// 根据 PHAsset 获取原始图片
-(void)getOriginImageWithPHAsset:(PHAsset *)asset imageBlock:(void(^)(UIImage *targetImage))imageBlock{
    
    
    [self.cacheManager requestImageDataForAsset:asset options:self.options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage  *originImage = [UIImage imageWithData:imageData];

            dispatch_async(dispatch_get_main_queue(), ^{
                imageBlock(originImage);
            });
        });
    }];
}





/// 根据 PHAsset 获取原始图片
-(void)getImagesWithLocalIdentifiers:(NSArray *)localIdentifiers imageType:(NSString *)imageType isOrigin:(BOOL)isOrigin targetSize:(CGSize )targetSize resultCallBack:(void(^)(NSArray *imageArr))resultArr{
    
    NSMutableArray *mutArr = [NSMutableArray array];
        
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
    

    for (PHAsset *asset in fetchResult) {
     
        self.options.synchronous = YES;
        
        if (isOrigin) {
            
            [self.cacheManager requestImageDataForAsset:asset options:self.options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                
                if ([imageType isEqualToString:@"UIImage"]) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [mutArr addObject:image];
                }else{
                    [mutArr addObject:imageData];
                }
                
            }];
            
        }else{
         
            ///优化图片输出尺寸
            if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
                targetSize = [self getFitSizeWithAsset:asset];
            }
            
            [self.cacheManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
               
                if ([imageType isEqualToString:@"UIImage"]) {
                    [mutArr addObject:result];
                }else{
                    NSData *data = UIImageJPEGRepresentation(result, 0.8);
                    [mutArr addObject:data];
                }
            }];
        }
    }
    
    resultArr(mutArr);
}

///后去适应当前屏幕尺寸的图片
- (CGSize)getFitSizeWithAsset:(PHAsset *)asset {
    
    CGSize targetSize = CGSizeZero;
    
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    CGFloat imgScale = width/height;
    
    CGFloat swidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat sheight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenScale = swidth/sheight;
    
    CGFloat newWidth = 0.0;
    CGFloat newHeight = 0.0;
    
    if (imgScale > screenScale) {
        ///宽作为最大值（固定屏高）
        newWidth = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
        newHeight = newWidth * height / width ;
        if (width > newWidth){
            targetSize = CGSizeMake(newWidth, newHeight);
        }else{
            targetSize = CGSizeMake(width, height);
        }
    }else{
        ///高作为最大值（固定屏宽）
        newHeight = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
        newWidth = newHeight * width / height ;
        if (height > newHeight){
            targetSize = CGSizeMake(newWidth, newHeight);
        }else{
            targetSize = CGSizeMake(width, height);
        }
    }
    return targetSize;
}



#pragma mark - init 属性初始化

-(PHCachingImageManager *)cacheManager{
    if (!_cacheManager) {
        _cacheManager = [[PHCachingImageManager alloc]init];
        _cacheManager.allowsCachingHighQualityImages = NO;
    }
    return _cacheManager;
}

- (PHImageManager *)manager{
    if (!_manager) {
        _manager = [[PHImageManager alloc]init];
    }
    return _manager;
}


-(PHImageRequestOptions *)options{

    if (!_options) {
        _options = [[PHImageRequestOptions alloc]init];
        _options.resizeMode = PHImageRequestOptionsResizeModeExact;
        _options.synchronous = NO;
    }
    return _options;
}

@end
