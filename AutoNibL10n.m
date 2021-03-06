//
//  AutoNibL10n.m
//  FoodReporter
//
//  Created by Olivier on 03/11/10.
//  Copyright 2010 FoodReporter. All rights reserved.
//

#import "AutoNibL10n.h"
#import <objc/runtime.h> 


static inline void localizeUIBarButtonItem(UIBarButtonItem* bbi);
static inline void localizeUIBarItem(UIBarItem* bi);
static inline void localizeUIButton(UIButton* btn);
static inline void localizeUILabel(UILabel* lbl);
static inline void localizeUINavigationItem(UINavigationItem* ni);
static inline void localizeUISearchBar(UISearchBar* sb);
static inline void localizeUISegmentedControl(UISegmentedControl* sc);
static inline void localizeUITextField(UITextField* tf);
static inline void localizeUITextView(UITextView* tv);
static inline void localizeUIViewController(UIViewController* vc);
	


@implementation AutoNibL10n
+(void)load {
	Method localizeNibObject = class_getInstanceMethod([NSObject class], @selector(localizeNibObject));
	Method awakeFromNib = class_getInstanceMethod([NSObject class], @selector(awakeFromNib));
	method_exchangeImplementations(awakeFromNib, localizeNibObject);
}
@end


@implementation NSObject(Auto_L10n)


#define LocalizeIfClass(Cls) if ([self isKindOfClass:[Cls class]]) localize##Cls((Cls*)self)
-(void)localizeNibObject {
	LocalizeIfClass(UIBarButtonItem);
	else LocalizeIfClass(UIBarItem);
	else LocalizeIfClass(UIButton);
	else LocalizeIfClass(UILabel);
	else LocalizeIfClass(UINavigationItem);
	else LocalizeIfClass(UISearchBar);
	else LocalizeIfClass(UISegmentedControl);
	else LocalizeIfClass(UITextField);
	else LocalizeIfClass(UITextView);
	else LocalizeIfClass(UIViewController);
	
	[self localizeNibObject]; // actually calls awakeFromNib as we did some method swizzling
}
@end

/////////////////////////////////////////////////////////////////////////////

static inline NSString* localizedString(NSString* aString) {
	if (aString == nil || [aString length] == 0)
		return aString;
	if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[aString characterAtIndex:0]])
		return aString;
	
	//NSString* tr = NSLocalizedString(aString, nil);
#if L10N_DEBUG
#warning L10n Debug mode ON
static NSString* const kNoTranslation = @"$!";
	NSString* tr = [[NSBundle mainBundle] localizedStringForKey:aString value:kNoTranslation table:nil];
	if ([tr isEqualToString:kNoTranslation]) {
		if ([aString characterAtIndex:0]=='.') {
			// strings in XIB starting with '.' are typically used as placeholder for design and will be replaced by translated text via code
			return aString;
		}
		NSLog(@"No translation for string '%@'",aString);
		tr = [NSString stringWithFormat:@"$%@$",aString];
	}
	return tr;
#else
	return [[NSBundle mainBundle] localizedStringForKey:aString value:nil table:nil];
#endif
}

/////////////////////////////////////////////////////////////////////////////

static inline void localizeUIBarButtonItem(UIBarButtonItem* bbi) {
	localizeUIBarItem(bbi); /* inheritence */
	
	NSMutableSet* locTitles = [[NSMutableSet alloc] initWithCapacity:[bbi.possibleTitles count]];
	for(NSString* str in bbi.possibleTitles) {
		[locTitles addObject:localizedString(str)];
	}
	bbi.possibleTitles = [NSSet setWithSet:locTitles];
	[locTitles release];
}

static inline void localizeUIBarItem(UIBarItem* bi) {
	bi.title = localizedString(bi.title);
}

static inline void localizeUIButton(UIButton* btn) {
	NSString* title[4] = {
		[btn titleForState:UIControlStateNormal],
		[btn titleForState:UIControlStateHighlighted],
		[btn titleForState:UIControlStateDisabled],
		[btn titleForState:UIControlStateSelected]
	};
	
	[btn setTitle:localizedString(title[0]) forState:UIControlStateNormal];
	if (title[1] == [btn titleForState:UIControlStateHighlighted])
		[btn setTitle:localizedString(title[1]) forState:UIControlStateHighlighted];
	if (title[2] == [btn titleForState:UIControlStateDisabled])
		[btn setTitle:localizedString(title[2]) forState:UIControlStateDisabled];
	if (title[3] == [btn titleForState:UIControlStateSelected])
		[btn setTitle:localizedString(title[3]) forState:UIControlStateSelected];
}

static inline void localizeUILabel(UILabel* lbl) {
	lbl.text = localizedString(lbl.text);
}

static inline void localizeUINavigationItem(UINavigationItem* ni) {
	ni.title = localizedString(ni.title);
	ni.prompt = localizedString(ni.prompt);
}

static inline void localizeUISearchBar(UISearchBar* sb) {
	sb.placeholder = localizedString(sb.placeholder);
	sb.prompt = localizedString(sb.prompt);
	sb.text = localizedString(sb.text);
	
	NSMutableArray* locScopesTitles = [[NSMutableArray alloc] initWithCapacity:[sb.scopeButtonTitles count]];
	for(NSString* str in sb.scopeButtonTitles) {
		[locScopesTitles addObject:localizedString(str)];
	}
	sb.scopeButtonTitles = [NSArray arrayWithArray:locScopesTitles];
	[locScopesTitles release];
}

static inline void localizeUISegmentedControl(UISegmentedControl* sc) {
	NSUInteger n = sc.numberOfSegments;
	for(NSUInteger idx = 0; idx<n; ++idx) {
		[sc setTitle:localizedString([sc titleForSegmentAtIndex:idx]) forSegmentAtIndex:idx];
	}
}

static inline void localizeUITextField(UITextField* tf) {
	tf.text = localizedString(tf.text);
	tf.placeholder = localizedString(tf.placeholder);
}

static inline void localizeUITextView(UITextView* tv) {
	tv.text = localizedString(tv.text);
}

static inline void localizeUIViewController(UIViewController* vc) {
	vc.title = localizedString(vc.title);
}
