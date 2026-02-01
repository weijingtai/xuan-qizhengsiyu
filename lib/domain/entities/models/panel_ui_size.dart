class QiZhengSiYuPanSizeDataModel {
  late final double centerSize;
  late final double diZhi12GongHeight;
  late final double zodiac12GongHeight;
  late final double starSeq12GongHeight;
  late final double destiny12GongHeight;
  late final double lifeStarRingHeight; // 564
  late final double starXiu28RingHeight; // 660
  late final double innerShenShaHeight;
  late final double outerShenShaHeight;

  double starBodyRadius;
  double get starBodySize => starBodyRadius * 2;
  late bool showFateLifeStarRing;

  late double diZhi12GongInner;
  late double diZhi12GongOuter;

  late double zodiac12GongSizeInner;
  late double zodiac12GongSizeOuter;

  late double starSeq12GongSizeInner;
  late double starSeq12GongSizeOuter;

  late double destiny12GongSizeInner;
  late double destiny12GongSizeOuter;

  late double innerShenShaSizeInner;
  late double innerShenShaSizeOuter;

  late double outerShenShaSizeInner;
  late double outerShenShaSizeOuter;

  late double innerLifeStarRingOuterSize; //564
  late double innerLifeStarRingTrackSize;
  late double innerLifeStarRingInnerSize;

  late double starXiu28RingSizeOuter; // 660
  late double starXiu28RingSizeInner; // 616 - 80 = 536

  late double outerLifeStarRingInnerSize; // starXiu28RingSizeOuter
  late double outerLifeStarRingTrackSize;
  late double outerLifeStarRingOuterSize;

  QiZhengSiYuPanSizeDataModel({
    required this.starBodyRadius,
    required this.centerSize,
    required this.diZhi12GongHeight,
    required this.zodiac12GongHeight,
    required this.starSeq12GongHeight,
    required this.destiny12GongHeight,
    required this.lifeStarRingHeight,
    required this.starXiu28RingHeight,
    required this.showFateLifeStarRing,
    required this.innerShenShaHeight,
    required this.outerShenShaHeight,
  }) {
    diZhi12GongInner = centerSize;
    diZhi12GongOuter = centerSize + diZhi12GongHeight * 2;

    zodiac12GongSizeInner = diZhi12GongOuter;
    zodiac12GongSizeOuter = diZhi12GongOuter + zodiac12GongHeight * 2;

    starSeq12GongSizeInner = zodiac12GongSizeOuter;
    starSeq12GongSizeOuter = zodiac12GongSizeOuter + starSeq12GongHeight * 2;

    destiny12GongSizeInner = starSeq12GongSizeOuter;
    destiny12GongSizeOuter = starSeq12GongSizeOuter + destiny12GongHeight * 2;

    innerLifeStarRingInnerSize = destiny12GongSizeOuter;
    innerLifeStarRingTrackSize =
        innerLifeStarRingInnerSize + lifeStarRingHeight;
    innerLifeStarRingOuterSize =
        innerLifeStarRingInnerSize + lifeStarRingHeight * 2;

    starXiu28RingSizeInner = innerLifeStarRingOuterSize;
    starXiu28RingSizeOuter = starXiu28RingSizeInner + starXiu28RingHeight * 2;

    outerLifeStarRingInnerSize =
        starXiu28RingSizeOuter; // starXiu28RingSizeOuter
    outerLifeStarRingTrackSize = starXiu28RingSizeOuter + lifeStarRingHeight;
    outerLifeStarRingOuterSize =
        starXiu28RingSizeOuter + lifeStarRingHeight * 2;

    innerShenShaSizeInner = outerLifeStarRingOuterSize;
    innerShenShaSizeOuter = innerShenShaSizeInner + innerShenShaHeight * 2;

    outerShenShaSizeInner = innerShenShaSizeOuter;
    outerShenShaSizeOuter = outerShenShaSizeInner + outerShenShaHeight * 2;
  }
}