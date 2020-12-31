import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

class AdMobManager {

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  String appID = Platform.isIOS
      ? 'ca-app-pub-4804939966855342~8291294074' // iOS Test App ID
      : 'ca-app-pub-4804939966855342~9621505857'; // Android Test App ID
  String bannerID = BannerAd.testAdUnitId;
  String interstitialID = InterstitialAd.testAdUnitId;

  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutter', 'firebase', 'admob'],
    testDevices: <String>[],
  );

  init() async {
    FirebaseAdMob.instance.initialize(appId: appID);
    _bannerAd = createBannerAd();
    _interstitialAd = createInterstitialAd();
    _bannerAd..load()..show(
      anchorOffset: 57.0,
      horizontalCenterOffset: 10.0,
      anchorType: AnchorType.bottom
    );
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerID,
      size: AdSize.banner,
      targetingInfo: targetingInfo,

      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: interstitialID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  showInterstitialAd() {
    _interstitialAd..load()..show();
  }


}