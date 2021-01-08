import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

class AdMobManager {


  static final AdMobManager _AdMobManager = AdMobManager._internal();

  factory AdMobManager(){
    return _AdMobManager;
  }
  AdMobManager._internal();
  BannerAd _bannerAd;
  //InterstitialAd _interstitialAd;

  String appID = Platform.isIOS
      ? 'ca-app-pub-4804939966855342~8291294074' // iOS actual App ID
      : 'ca-app-pub-4804939966855342~9621505857'; // Android actual App ID
  String bannerID = BannerAd.testAdUnitId; //test banner ID
  //String interstitialID = InterstitialAd.testAdUnitId; //test interstitual ID

  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['Game', 'LOL', 'Business'], //keyword는 마음대로 원하는 단어 넣어주면됨.
    testDevices: <String>[], //실제 광고적용시 자기 deviceID를 넣어줘야함.
  );

  init() async {
    FirebaseAdMob.instance.initialize(appId: appID);
    _bannerAd = createBannerAd()..load();

    //_interstitialAd = createInterstitialAd();

    /*..show(
      anchorOffset: 57.0,
      horizontalCenterOffset: 10.0,
      anchorType: AnchorType.bottom
    );*/
  }

  showBanner() {
    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show(
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
  removeBannerAd(){
    _bannerAd?.dispose();
    _bannerAd=null;
  }

  /*InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: interstitialID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }*/

  /*showInterstitialAd() {
    _interstitialAd..load()..show();
  }*/




}