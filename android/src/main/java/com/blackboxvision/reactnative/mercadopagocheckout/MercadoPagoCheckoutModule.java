package com.blackboxvision.reactnative.mercadopagocheckout;

import android.app.Activity;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.text.TextUtils;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

import com.mercadopago.core.MercadoPagoCheckout;
import com.mercadopago.preferences.CheckoutPreference;
import com.mercadopago.preferences.DecorationPreference;
import com.mercadopago.preferences.FlowPreference;
import com.mercadopago.preferences.ServicePreference;

import java.util.HashMap;
import java.util.Map;

public final class MercadoPagoCheckoutModule extends ReactContextBaseJavaModule {
    private MercadoPagoCheckoutEventListener eventResultListener;

    public MercadoPagoCheckoutModule(ReactApplicationContext context) {
        super(context);
        init(context);
    }

    private void init(@NonNull ReactApplicationContext context) {
        eventResultListener = new MercadoPagoCheckoutEventListener();
        context.addActivityEventListener(eventResultListener);
    }

    @Override
    public String getName() {
        return "MercadoPagoCheckoutModule";
    }

    public void onNewIntent(Intent intent) { }

    @ReactMethod
    public void startCheckoutForPayment(@NonNull String publicKey, @NonNull String checkoutPreferenceId, @NonNull String hexColor, @NonNull Boolean enableDarkFont, @NonNull Promise promise) {
        this.setCurrentPromise(promise);

        //Create a decoration preference
        final DecorationPreference decorationPreference = this.createDecorationPreference(hexColor, enableDarkFont);
        final CheckoutPreference checkoutPreference = new CheckoutPreference(checkoutPreferenceId);
        final Activity currentActivity = this.getCurrentActivity();

        new MercadoPagoCheckout.Builder()
                .setDecorationPreference(decorationPreference)
                .setCheckoutPreference(checkoutPreference)
                .setActivity(currentActivity)
                .setPublicKey(publicKey)
                .startForPayment();
    }

    @ReactMethod
    public void startCheckoutForPaymentData(@NonNull String publicKey, @NonNull String checkoutPreferenceId, @NonNull String hexColor, @NonNull Boolean enableDarkFont, @NonNull Promise promise) {
        this.setCurrentPromise(promise);

        //Create a decoration preference
        final DecorationPreference decorationPreference = this.createDecorationPreference(hexColor, enableDarkFont);
        final CheckoutPreference checkoutPreference = new CheckoutPreference(checkoutPreferenceId);
        final Activity currentActivity = this.getCurrentActivity();

        new MercadoPagoCheckout.Builder()
                .setDecorationPreference(decorationPreference)
                .setCheckoutPreference(checkoutPreference)
                .setActivity(currentActivity)
                .setPublicKey(publicKey)
                .startForPaymentData();
    }

    @ReactMethod
    public void collectPaymentDataFor(@NonNull String publicKey, @NonNull String accessToken, @NonNull String checkoutPreferenceId, @NonNull String customerId, @NonNull Promise promise) {
        this.setCurrentPromise(promise);

        final DecorationPreference decorationPreference = this.createDecorationPreference("#C82027", false);
        final FlowPreference flowPreference = this.createFlowPreference();
        final CheckoutPreference checkoutPreference = new CheckoutPreference(checkoutPreferenceId);
        final Activity currentActivity = this.getCurrentActivity();

        if (TextUtils.isEmpty(customerId)) {
            new MercadoPagoCheckout.Builder()
                .setDecorationPreference(decorationPreference)
                .setFlowPreference(flowPreference)
                .setCheckoutPreference(checkoutPreference)
                .setActivity(currentActivity)
                .setPublicKey(publicKey)
                .startForPaymentData();
        }
        else {
            new MercadoPagoCheckout.Builder()
                .setDecorationPreference(decorationPreference)
                .setFlowPreference(flowPreference)
                .setCheckoutPreference(checkoutPreference)
                .setServicePreference(this.createServicePreference(accessToken, customerId))
                .setActivity(currentActivity)
                .setPublicKey(publicKey)
                .startForPaymentData();
        }
    }

    private DecorationPreference createDecorationPreference(@NonNull String color, @NonNull Boolean enableDarkFont) {
        final DecorationPreference.Builder preferenceBuilder = new DecorationPreference.Builder().setBaseColor(color);

        if (enableDarkFont) {
            preferenceBuilder.enableDarkFont();
        }

       return preferenceBuilder.build();
    }

    private FlowPreference createFlowPreference() {
        final FlowPreference.Builder preferenceBuilder = new FlowPreference.Builder();
        preferenceBuilder.disableBankDeals();
        preferenceBuilder.disableDiscount();
//        preferenceBuilder.disablePaymentResultScreen();
//        preferenceBuilder.disablePaymentPendingScreen();
//        preferenceBuilder.disablePaymentApprovedScreen();
//        preferenceBuilder.disablePaymentRejectedScreen();
//        preferenceBuilder.disableReviewAndConfirmScreen();
        preferenceBuilder.disableInstallmentsReviewScreen();
        preferenceBuilder.setMaxSavedCardsToShow(FlowPreference.SHOW_ALL_SAVED_CARDS_CODE);
        return preferenceBuilder.build();
    }

    private ServicePreference createServicePreference(@NonNull String accessToken, @NonNull String customerId) {
        final ServicePreference.Builder preferenceBuilder = new ServicePreference.Builder();
        
        final Map<String, String> additionalInfo = new HashMap<>();
        additionalInfo.put("access_token", accessToken);

        preferenceBuilder.setGetCustomerURL("https://api.mercadopago.com", ("/v1/customers/" + customerId), additionalInfo);

        return preferenceBuilder.build();
    }

    private void setCurrentPromise(@NonNull Promise promise) {
        eventResultListener.setCurrentPromise(promise);
    }
}
