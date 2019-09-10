#import "CheckoutMercadoPagoModule.h"
#import "AppDelegate.h"

@import MercadoPagoSDK;

@implementation MercadoPagoCheckoutModule

RCT_EXPORT_MODULE()

- (dispatch_queue_t) methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(startCheckoutForPayment: (NSString *) publicKey: (NSString *) preferenceId: (NSString *) color: (BOOL) enableDarkFont: (RCTPromiseResolveBlock) resolve: (RCTPromiseRejectBlock) reject) {
    //Get UINavigationController from AppDelegate
    AppDelegate *share = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *uiNavigationController = (UINavigationController *) share.window.rootViewController;

    //Set DecorationPreference on MercadoPagoCheckout
    DecorationPreference *decorationPreference = [[DecorationPreference alloc] initWithBaseColor:[UIColor fromHex:color]];
    [MercadoPagoCheckout setDecorationPreference: decorationPreference];

    //Set CheckoutPreference on MercadoPagoCheckout
    CheckoutPreference *preference = [[CheckoutPreference alloc] initWith_id:preferenceId];
    MercadoPagoCheckout *checkout = [[MercadoPagoCheckout alloc] initWithPublicKey:publicKey checkoutPreference:preference discount:nil navigationController:uiNavigationController];

    //Set up Cancellation Callback
    [checkout setCallbackCancelWithCallback:^{
        [uiNavigationController setNavigationBarHidden:TRUE];
        [uiNavigationController popToRootViewControllerAnimated:NO];

        reject(@"PAYMENT_CANCELLED", @"Payment was cancelled by the user.", nil);
    }];

    //Set up Payment Callback
    [MercadoPagoCheckout setPaymentCallbackWithPaymentCallback:^(Payment * payment) {
        if (payment != nil) {
            NSDictionary *paymentDictionary = @{@"id": payment._id, @"status": payment.status};

            resolve(paymentDictionary);
        } else {
            NSLog(@"PaymentResult is NIL.");
        }

        [uiNavigationController setNavigationBarHidden:TRUE];
        [uiNavigationController popToRootViewControllerAnimated:NO];
    }];

    [checkout start];

    [uiNavigationController setNavigationBarHidden:FALSE];
}

RCT_EXPORT_METHOD(startCheckoutForPaymentData: (NSString *) publicKey: (NSString *) preferenceId: (NSString *) color: (BOOL) enableDarkFont: (RCTPromiseResolveBlock) resolve: (RCTPromiseRejectBlock) reject) {
    //Get UINavigationController from AppDelegate
    AppDelegate *share = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *uiNavigationController = (UINavigationController *) share.window.rootViewController;

    //Set DecorationPreference on MercadoPagoCheckout
    DecorationPreference *decorationPreference = [[DecorationPreference alloc] initWithBaseColor:[UIColor fromHex:color]];
    [MercadoPagoCheckout setDecorationPreference: decorationPreference];

    //Set CheckoutPreference on MercadoPagoCheckout
    CheckoutPreference *preference = [[CheckoutPreference alloc] initWith_id:preferenceId];
    MercadoPagoCheckout *checkout = [[MercadoPagoCheckout alloc] initWithPublicKey:publicKey checkoutPreference:preference discount:nil navigationController:uiNavigationController];

    //Set up Cancellation Callback
    [checkout setCallbackCancelWithCallback:^{
        [uiNavigationController setNavigationBarHidden:TRUE];
        [uiNavigationController popToRootViewControllerAnimated:NO];

        reject(@"PAYMENT_CANCELLED", @"Payment was cancelled by the user.", nil);
    }];

    //Set up PaymentData Callback
    [MercadoPagoCheckout setPaymentDataConfirmCallbackWithPaymentDataConfirmCallback:^(PaymentData * paymentData) {
        if (paymentData != nil) {
            NSString *campaignId = paymentData.discount._id != nil ? paymentData.discount._id : @"";
            NSString *installments = [@(paymentData.payerCost.installments) stringValue];
            NSString *paymentMethodId = paymentData.paymentMethod._id;
            NSString *cardIssuerId = paymentData.issuer._id != nil ? paymentData.issuer._id : @"";
            NSString *cardTokenId = paymentData.token._id;

            NSDictionary *paymentDataDictionary = @{@"paymentMethodId": paymentMethodId, @"cardTokenId": cardTokenId, @"cardIssuerId": cardIssuerId, @"installments": installments, @"campaignId": campaignId };

            resolve(paymentDataDictionary);
        } else {
            NSLog(@"PaymentData is NIL.");
        }

        [uiNavigationController setNavigationBarHidden:TRUE];
        [uiNavigationController popToRootViewControllerAnimated:NO];
    }];

    [checkout start];

    [uiNavigationController setNavigationBarHidden:FALSE];
}

RCT_EXPORT_METHOD(collectPaymentDataFor:(NSString *)publicKey :(NSString *)accessToken :(NSString *)preferenceId :(NSString *)customerId :(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock) reject) {
	//Get UINavigationController from AppDelegate
	AppDelegate *share = (AppDelegate *)[UIApplication sharedApplication].delegate;
	UINavigationController *uiNavigationController = (UINavigationController *) share.window.rootViewController;

	//Set DecorationPreference on MercadoPagoCheckout
	UIColor *mainColor = [UIColor colorWithRed:200/255.0 green:32/255.0 blue:39/255.0 alpha:1.0];
	DecorationPreference *decorationPreference = [[DecorationPreference alloc] initWithBaseColor:mainColor];
	[MercadoPagoCheckout setDecorationPreference: decorationPreference];

	[MercadoPagoContext setLanguageWithLanguage:Languages_SPANISH];

	//Set CheckoutPreference on MercadoPagoCheckout
	CheckoutPreference *preference = [[CheckoutPreference alloc] initWith_id:preferenceId];
	MercadoPagoCheckout *checkout = [[MercadoPagoCheckout alloc] initWithPublicKey:publicKey checkoutPreference:preference discount:nil navigationController:uiNavigationController];

	//Set FlowPreference on MercadoPagoCheckout
	FlowPreference *flowPreference = [[FlowPreference alloc] init];
	[flowPreference disableESC];
	[flowPreference disableDiscount];
	[flowPreference disableBankDeals];
//	[flowPreference disableDefaultSelection];
//	[flowPreference disablePaymentResultScreen];
//	[flowPreference disablePaymentPendingScreen];
//	[flowPreference disablePaymentApprovedScreen];
//	[flowPreference disablePaymentRejectedScreen];
//	[flowPreference disableReviewAndConfirmScreen];
	[flowPreference disableInstallmentsReviewScreen];
    [flowPreference setMaxSavedCardsToShowFromString:@"all"];
	[MercadoPagoCheckout setFlowPreference:flowPreference];

    if (accessToken && customerId && [customerId isKindOfClass:[NSString class]] && ![@"" isEqualToString:customerId]) {
        NSString* baseURL = @"https://api.mercadopago.com"; //URLConfigs.MP_API_BASE_URL
        NSString* customerURI = [NSString stringWithFormat:@"/v1/customers/%@", customerId];
        NSDictionary* additionalInfo = @{@"access_token": accessToken};

        ServicePreference *servicePreference = [[ServicePreference alloc] init];
        [servicePreference setGetCustomerWithBaseURL:baseURL URI:customerURI additionalInfo:additionalInfo];
        [MercadoPagoCheckout setServicePreference:servicePreference];
    }

	//Set up Cancellation Callback
	[checkout setCallbackCancelWithCallback:^{
		[uiNavigationController setNavigationBarHidden:TRUE];
		[uiNavigationController popToRootViewControllerAnimated:NO];

		reject(@"PAYMENT_CANCELLED", @"Payment was cancelled by the user.", nil);
	}];

	//Set up PaymentData Callback
	[MercadoPagoCheckout setPaymentDataConfirmCallbackWithPaymentDataConfirmCallback:^(PaymentData * paymentData) {
		if (paymentData != nil) {
			NSString *campaignId = paymentData.discount._id != nil ? paymentData.discount._id : @"";
			NSString *installments = [@(paymentData.payerCost.installments) stringValue];
			NSString *paymentMethodId = paymentData.paymentMethod._id;
			NSString *cardIssuerId = paymentData.issuer._id != nil ? paymentData.issuer._id : @"";
			NSString *cardTokenId = paymentData.token._id;

			NSDictionary *paymentDataDictionary = @{@"paymentMethodId": paymentMethodId, @"cardTokenId": cardTokenId, @"cardIssuerId": cardIssuerId, @"installments": installments, @"campaignId": campaignId };

			resolve(paymentDataDictionary);
		}
		else {
			reject(@"PAYMENT_FAILED", @"PaymentData is NIL", nil);
		}

		[uiNavigationController setNavigationBarHidden:TRUE];
		[uiNavigationController popToRootViewControllerAnimated:NO];
	}];

	[checkout start];

	[uiNavigationController setNavigationBarHidden:FALSE];
}

@end
