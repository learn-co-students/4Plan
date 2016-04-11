//
//  ViewController.m
//  FurnitureInteraction
//
//  Created by susan lovaglio on 3/29/16.
//  Copyright © 2016 susan lovaglio. All rights reserved.
//

#import "SMLViewController.h"
#import "FPCStateManager.h"
#import "ENWFurniture.h"
#import "DimensionsViewController.h"


#import "FurnitureButton.h"
#import "EnterRoomDimensionViewController.h"
#import "FPCItemsMenuViewController.h"

#import <Masonry/Masonry.h>

@interface SMLViewController () <UIPopoverPresentationControllerDelegate, DimensionViewControllerDelegate>

@property (strong, nonatomic) FPCStateManager *dataStore;
@property (strong, nonatomic) UIView *roomLayoutView;
@property (strong, nonatomic) FurnitureButton *deleteButton;
@property (strong, nonatomic) ENWFurniture *itemToDelete;
@property (strong, nonatomic) FurnitureButton *furnitureButtonToDelete;
<<<<<<< HEAD
@property (strong, nonatomic) DimensionsViewController *dimensionsvc;

@property (strong, nonatomic) FurnitureButton *tappedFurnitureButton;
=======
@property (strong, nonatomic) UIView *itemsMenuContainerView;
@property (strong, nonatomic) UIView *recognizerLayerView;
@property (strong, nonatomic) NSLayoutConstraint *itemsMenuTrailing;
@property (assign, nonatomic) BOOL isMenuOut;
>>>>>>> master

@end

@implementation SMLViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self constrainForFloorPlan]; //MV
    [self barButtonItem]; //MV

    [self constraintsForItemsMenu];
    [self furnitureTouching];
    self.dimensionsvc.delegate=self;
    
}

-(void) barButtonItem {
    
    UIImage *addSymbol = [UIImage imageNamed:@"addFurnitureButtonSmall"];
    UIBarButtonItem *furnitureBarButton = [[UIBarButtonItem alloc]initWithImage: addSymbol style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
    self.navigationItem.rightBarButtonItem = furnitureBarButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    furnitureBarButton.imageInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    [self.navigationItem setRightBarButtonItem:furnitureBarButton];
    
}

-(void) buttonAction: (id) sender {
 

    [self showDismissMenu];
//    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    FPCItemsMenuViewController *newVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"FPCItemsMenuViewController"];
//    [self presentViewController:newVC animated:YES completion:nil];
}

-(void) constrainForFloorPlan {

    self.dataStore = [FPCStateManager currentState];

    CGFloat roomLayoutBorder = 1.0;
    CGFloat roomLayoutPadding = 20.0;
    

    self.roomLayoutView = [[UIView alloc] init];
    [self.view addSubview:self.roomLayoutView];
    
    NSLog(@"width entered %lu", self.dataStore.room.w);
    NSLog(@"length entered %lu", self.dataStore.room.l);
    
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height - (navHeight + statusBarHeight);
    
    CGFloat enteredWidth = self.dataStore.room.w;
    CGFloat enteredHeight = self.dataStore.room.l;
    
    CGFloat widthFactor = viewWidth / enteredWidth;
    CGFloat heightFactor = viewHeight / enteredHeight;
    
    CGFloat scaleFactor;
    
    if (widthFactor < heightFactor) {
        scaleFactor = widthFactor;
    } else {
        scaleFactor = heightFactor;
    }
    
    CGFloat floorWidth = enteredWidth * scaleFactor;
    CGFloat floorHeight = enteredHeight * scaleFactor;
    
    floorWidth = floorWidth - roomLayoutBorder - (roomLayoutPadding * 2);
    floorHeight = floorHeight - roomLayoutBorder - (roomLayoutPadding * 2);

    self.roomLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat topAnchorConstant = navHeight + statusBarHeight + roomLayoutPadding;
    [self.roomLayoutView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.roomLayoutView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active =YES;
    [self.roomLayoutView.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.topAnchor constant:topAnchorConstant].active = YES;
    [self.roomLayoutView.widthAnchor constraintEqualToConstant:floorWidth].active = YES;
    [self.roomLayoutView.heightAnchor constraintEqualToConstant:floorHeight].active = YES;

    
    [self.roomLayoutView layoutIfNeeded];
    
    self.roomLayoutView.layer.borderColor = [UIColor blackColor].CGColor;
    self.roomLayoutView.layer.borderWidth = roomLayoutBorder;
    self.roomLayoutView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
}

-(void)constraintsForItemsMenu {
//    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
//    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.isMenuOut = NO;
    self.recognizerLayerView = [[UIView alloc] init];
    self.recognizerLayerView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    self.recognizerLayerView.alpha = 0;
    UITapGestureRecognizer *quitTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDismissMenu)];
    [self.recognizerLayerView addGestureRecognizer:quitTap];
    
    self.itemsMenuContainerView = [[UIView alloc] init];
    UINavigationController *menuNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"Items Menu Navigation Controller"];

    // Adding to [subviews]
    [self.view addSubview:self.recognizerLayerView];
    [self.view addSubview:self.itemsMenuContainerView];
    
    // Giving constraints
    [self.recognizerLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.itemsMenuContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).multipliedBy(0.75);
        make.top.and.bottom.equalTo(self.view);
    }];
    CGFloat offset = self.view.frame.size.width * 0.75;
    self.itemsMenuTrailing = [self.itemsMenuContainerView.trailingAnchor
        constraintEqualToAnchor:self.view.trailingAnchor
        constant:offset - 8];
    self.itemsMenuTrailing.active = YES;

    // Setting the embedded FPCItemsMenuViewController
    [self setEmbeddedViewController:menuNavC];
}

-(void)setEmbeddedViewController:(UIViewController *)controller
{
    if([self.childViewControllers containsObject:controller]) {
        return;
    }
    
    for(UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        
        if(vc.isViewLoaded) {
            [vc.view removeFromSuperview];
        }
        
        [vc removeFromParentViewController];
    }
    
    if(!controller) {
        return;
    }
    
    [self addChildViewController:controller];
    [self.itemsMenuContainerView addSubview:controller.view];
    [controller.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    [controller didMoveToParentViewController:self];
}


-(void)showDismissMenu {
    CGFloat offset, alpha;
    
    if (self.isMenuOut) {
        alpha = 0;
        offset = self.itemsMenuContainerView.frame.size.width - 8;
    }
    else {
        alpha = 0.6;
        offset = 8;
    }
    
    [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.recognizerLayerView.alpha = alpha;
        self.itemsMenuTrailing.constant = offset;
        [self.view layoutIfNeeded];
        self.isMenuOut = !self.isMenuOut;
    } completion:nil];

}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.deleteButton removeFromSuperview];
    
    self.view.backgroundColor = [UIColor colorWithHue:0.256 saturation:0.35 brightness:1.0 alpha:1];
    
    self.dataStore = [FPCStateManager currentState];
    ENWFurniture *newlyAddedPiece = self.dataStore.arrangedFurniture.lastObject;
    if (!self.dataStore.arrangedButtons) {
        self.dataStore.arrangedButtons=[NSMutableArray<FurnitureButton *> new];
    }
    
    if (newlyAddedPiece) {
        
        FurnitureButton *placedPiece = [[FurnitureButton alloc]init];
        [placedPiece setBackgroundImage:newlyAddedPiece.image forState:normal];
        placedPiece.imageView.image = newlyAddedPiece.image;
        placedPiece.imageView.contentMode = UIViewContentModeScaleToFill;
        placedPiece.backgroundColor = [UIColor darkGrayColor];
        placedPiece.tintColor = [UIColor blackColor];
        placedPiece.furnitureItem = newlyAddedPiece;
        
        UIPanGestureRecognizer *panGestureRecognizerSofa = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveFurniture:)];
        [placedPiece addGestureRecognizer:panGestureRecognizerSofa];
        
        UIRotationGestureRecognizer *rotationGestureRecognizerSofa = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotateFurniture:)];
        [placedPiece addGestureRecognizer:rotationGestureRecognizerSofa];
        
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(deleteFurniture:)];
        longPressGestureRecognizer.minimumPressDuration = .3;
        [placedPiece addGestureRecognizer:longPressGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDimensionsPopOver:)];
        [placedPiece addGestureRecognizer: tapGestureRecognizer];
        
        [self.roomLayoutView addSubview:placedPiece];
                
        CGFloat xConstant = (self.roomLayoutView.frame.size.width / 2) - (placedPiece.furnitureItem.width / 2);
        CGFloat yConstant = (self.roomLayoutView.frame.size.height / 2) - (placedPiece.furnitureItem.length / 2);
        
        
        placedPiece.translatesAutoresizingMaskIntoConstraints = NO;
        
        placedPiece.xPosition = [placedPiece.leftAnchor constraintEqualToAnchor:self.roomLayoutView.leftAnchor constant:xConstant];
        placedPiece.yPosition = [placedPiece.topAnchor constraintEqualToAnchor:self.roomLayoutView.topAnchor constant:yConstant];
        placedPiece.xPosition.active = YES;
        placedPiece.yPosition.active = YES;
        
        
        CGFloat widthscale= self.view.bounds.size.width/self.dataStore.room.w;
        CGFloat lengthscale=self.view.bounds.size.height/self.dataStore.room.l;
        placedPiece.furnitureItem.width=placedPiece.furnitureItem.width*widthscale;
        placedPiece.furnitureItem.length=placedPiece.furnitureItem.length*lengthscale;
        placedPiece.widthConstraint = [placedPiece.widthAnchor constraintEqualToConstant:placedPiece.furnitureItem.width];
        placedPiece.lengthConstraint = [placedPiece.heightAnchor constraintEqualToConstant:placedPiece.furnitureItem.length];
        
        placedPiece.widthConstraint.active = YES;
        placedPiece.lengthConstraint.active = YES;
        
        
    [self.dataStore.arrangedButtons addObject:placedPiece];
        
        NSLog(@"%@",self.dataStore.arrangedButtons);
//        NSLog(@"\n\nnewly added piece:\nx: %f\ny: %f\nwidth: %f\nheight: %f\n\n",placedPiece.xPosition.constant, placedPiece.yPosition.constant,placedPiece.widthConstraint.constant,placedPiece.lengthConstraint.constant);
        
    }
    [self furnitureTouching];
}



-(void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    [self doTheThing];
    
//    DimensionsViewController *dimensionsVC = (DimensionsViewController *) popoverPresentationController;
//    
//    dimensionsVC.furnitureButton.widthConstraint = [dimensionsVC.furnitureButton.widthAnchor constraintEqualToConstant:dimensionsVC.furnitureButton.furnitureItem.width];
//    dimensionsVC.furnitureButton.lengthConstraint = [dimensionsVC.furnitureButton.heightAnchor constraintEqualToConstant:dimensionsVC.furnitureButton.furnitureItem.length];
//    [self.view layoutIfNeeded];
    
}

-(void) doTheThing {
    [self.tappedFurnitureButton removeConstraint:self.tappedFurnitureButton.widthConstraint];
    [self.tappedFurnitureButton removeConstraint:self.tappedFurnitureButton.lengthConstraint];

    CGFloat widthscale= self.view.bounds.size.width/self.dataStore.room.w;
    CGFloat lengthscale=self.view.bounds.size.height/self.dataStore.room.l;
    self.tappedFurnitureButton.furnitureItem.width=self.tappedFurnitureButton.furnitureItem.width*widthscale;
    self.tappedFurnitureButton.furnitureItem.length=self.tappedFurnitureButton.furnitureItem.length*lengthscale;
    
    self.tappedFurnitureButton.widthConstraint = [self.tappedFurnitureButton.widthAnchor constraintEqualToConstant:self.tappedFurnitureButton.furnitureItem.width];
    self.tappedFurnitureButton.lengthConstraint = [self.tappedFurnitureButton.heightAnchor constraintEqualToConstant:self.tappedFurnitureButton.furnitureItem.length];
    
    self.tappedFurnitureButton.widthConstraint.active=YES;
    self.tappedFurnitureButton.lengthConstraint.active=YES;
    [self.view layoutIfNeeded];
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController*)controller {
    
    return UIModalPresentationNone;
    
}

-(void)showDimensionsPopOver: (UITapGestureRecognizer*)tapGesture{

    [self.deleteButton removeFromSuperview];
    
    FurnitureButton *button = (FurnitureButton *)tapGesture.view;
    self.tappedFurnitureButton = button;
    ENWFurniture *furniture = button.furnitureItem;
    DimensionsViewController *dimvc = [self.storyboard instantiateViewControllerWithIdentifier:@"dimensionVC"];
    dimvc.furniture = furniture;
    dimvc.furnitureButton = button;
    dimvc.preferredContentSize = CGSizeMake(160, 140);
    
    dimvc.modalPresentationStyle = UIModalPresentationPopover;
    dimvc.delegate = self;
    UIPopoverPresentationController *popov = dimvc.popoverPresentationController;
    popov.delegate = self;
    popov.sourceView = tapGesture.view;
    popov.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    [self presentViewController:dimvc animated:YES completion:nil];
    
    NSLog(@"%@",self.dataStore.arrangedFurniture.lastObject);
    NSLog(@"%@",self.dataStore.arrangedButtons.lastObject);
    
}

-(void)moveFurniture:(UIPanGestureRecognizer*)panGestureRecognizer{
    
    [self.deleteButton removeFromSuperview];
    
    FurnitureButton *selectedFurniture = (FurnitureButton*)panGestureRecognizer.view;
    
    CGPoint touchLocation = [panGestureRecognizer translationInView:self.roomLayoutView];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
    touchLocation = [panGestureRecognizer locationInView:self.roomLayoutView];
        
//    CGPoint leadingEdgeofFurniture = CGPointMake(touchLocation.x - (selectedFurniture.bounds.size.width/2), 0);
//    
//    CGPoint trailingEdgeOfFurniture = CGPointMake(touchLocation.x + (selectedFurniture.bounds.size.width/2), 0);
//    
//    CGPoint topOfFurniture = CGPointMake(0, touchLocation.y - (selectedFurniture.bounds.size.height/2));
//
//    CGPoint bottomOfFurniture = CGPointMake(0, touchLocation.y + (selectedFurniture.bounds.size.height/2));
//
//    CGPoint topBorder = self.roomLayoutView.bounds.origin;
//    
//    CGPoint bottomBorder = CGPointMake(self.roomLayoutView.bounds.origin.x + self.roomLayoutView.bounds.size.width, self.roomLayoutView.bounds.origin.y + self.roomLayoutView.bounds.size.height);
//    
//    BOOL outOfBounds = leadingEdgeofFurniture.x < topBorder.x - 3 || topOfFurniture.y < topBorder.y - 3 || trailingEdgeOfFurniture.x > bottomBorder.x + 3 || bottomOfFurniture.y > bottomBorder.y + 3;
//    
//    if (outOfBounds) {
//        NSLog(@"out of bounds");
//    }else{

        selectedFurniture.center = touchLocation;
//        selectedFurniture.xPosition.constant += touchLocation.x;
//        selectedFurniture.yPosition.constant += touchLocation.y;
//        }

    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        selectedFurniture.xPosition.constant += touchLocation.x;
        selectedFurniture.yPosition.constant += touchLocation.y;
        
    }
    [self furnitureTouching];

}

-(void)rotateFurniture:(UIRotationGestureRecognizer*)rotateGestureRecognizer{
    
    [self.deleteButton removeFromSuperview];
    
    if (rotateGestureRecognizer.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    rotateGestureRecognizer.view.transform = CGAffineTransformRotate(rotateGestureRecognizer.view.transform, rotateGestureRecognizer.rotation);
    
    rotateGestureRecognizer.rotation = 0;
    
    [self furnitureTouching];
}

-(void)deleteFurniture:(UILongPressGestureRecognizer*)longPressGestureRecognizer{

    UIImage *image = [UIImage imageNamed:@"delete"];
    FurnitureButton *selectedButton = (FurnitureButton *)longPressGestureRecognizer.view;
    CGPoint touchLocation = [longPressGestureRecognizer locationInView:self.roomLayoutView];
    
    if(longPressGestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    self.furnitureButtonToDelete = selectedButton;
    self.itemToDelete = selectedButton.furnitureItem;
    self.deleteButton = [[FurnitureButton alloc]init];
    [self.deleteButton setImage:image forState:UIControlStateNormal];
    [self.roomLayoutView addSubview:self.deleteButton];
    
    self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deleteButton.widthAnchor constraintEqualToAnchor:longPressGestureRecognizer.view.widthAnchor multiplier:.7].active = YES;
    [self.deleteButton.heightAnchor constraintEqualToAnchor:longPressGestureRecognizer.view.heightAnchor multiplier:.4].active = YES;
    
    [self.deleteButton.centerYAnchor constraintEqualToAnchor:longPressGestureRecognizer.view.topAnchor].active = YES;
    [self.deleteButton.centerXAnchor constraintEqualToAnchor:longPressGestureRecognizer.view.leadingAnchor].active = YES;
    
    longPressGestureRecognizer.view.center = touchLocation;
    self.deleteButton.center = longPressGestureRecognizer.view.center;
    UITapGestureRecognizer *tappedTheX = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedTheXButton:)];
    [self.deleteButton addGestureRecognizer:tappedTheX];
    
}

-(void)tappedTheXButton:(UITapGestureRecognizer*)theX {

    [self.deleteButton removeFromSuperview];
    
    [self.dataStore.arrangedFurniture removeObject:self.itemToDelete];
   
    [self.dataStore.arrangedButtons removeObject:self.furnitureButtonToDelete];
    [self.furnitureButtonToDelete removeFromSuperview];
}

-(BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

-(void)furnitureTouching{
    
    for (FurnitureButton *button in self.roomLayoutView.subviews) {
        BOOL shouldBeRed = NO;
        for (FurnitureButton *buttonAgain in self.roomLayoutView.subviews) {
            if (button == buttonAgain) { continue; }
            BOOL buttonButtonAgainTouching = CGRectIntersectsRect(button.frame, buttonAgain.frame);
            if(buttonButtonAgainTouching){
                shouldBeRed = YES;
                break;
            }
        }
        button.tintColor = shouldBeRed ? [UIColor redColor] : [UIColor blackColor];
    }
}

@end

