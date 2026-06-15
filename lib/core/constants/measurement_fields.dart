class MeasurementFields {
  MeasurementFields._();

  static const Map<String, List<MeasurementFieldDef>> categories = {
    "shalwar_kameez": _shalwarKameez,
    "mens_suit": _mensSuit,
    "kurta": _kurta,
    "waistcoat": _waistcoat,
    "pants": _pants,
    "shirt": _shirt,
    "womens_dress": _womensDress,
  };

  static const Map<String, String> categoryLabelsEn = {
    "shalwar_kameez": "Shalwar Kameez",
    "mens_suit": "Men's Suit",
    "kurta": "Kurta",
    "waistcoat": "Waistcoat",
    "pants": "Pants",
    "shirt": "Shirt",
    "womens_dress": "Women's Dress",
  };

  static const Map<String, String> categoryLabelsUr = {
    "shalwar_kameez": "شلوار قمیض",
    "mens_suit": "مردانہ سوٹ",
    "kurta": "کرتا",
    "waistcoat": "واسکٹ",
    "pants": "پتلون",
    "shirt": "شرٹ",
    "womens_dress": "خواتین لباس",
  };

  // ── Shalwar Kameez ──
  static const List<MeasurementFieldDef> _shalwarKameez = [
    MeasurementFieldDef(key: "kameez_length", labelEn: "Kameez Length", labelUr: "قمیض لمبائی"),
    MeasurementFieldDef(key: "chest", labelEn: "Chest", labelUr: "سینہ"),
    MeasurementFieldDef(key: "shoulder", labelEn: "Shoulder", labelUr: "کندھا"),
    MeasurementFieldDef(key: "sleeves", labelEn: "Sleeves", labelUr: "آستین"),
    MeasurementFieldDef(key: "collar", labelEn: "Collar", labelUr: "گلا"),
    MeasurementFieldDef(key: "daman", labelEn: "Daman", labelUr: "دامن"),
    MeasurementFieldDef(key: "shalwar_length", labelEn: "Shalwar Length", labelUr: "شلوار لمبائی"),
    MeasurementFieldDef(key: "shalwar_pancha", labelEn: "Pancha", labelUr: "پانچہ"),
    MeasurementFieldDef(key: "waist", labelEn: "Waist", labelUr: "کمر"),
  ];

  // ── Men's Suit ──
  static const List<MeasurementFieldDef> _mensSuit = [
    MeasurementFieldDef(key: "coat_length", labelEn: "Coat Length", labelUr: "کوٹ لمبائی"),
    MeasurementFieldDef(key: "chest", labelEn: "Chest", labelUr: "سینہ"),
    MeasurementFieldDef(key: "shoulder", labelEn: "Shoulder", labelUr: "کندھا"),
    MeasurementFieldDef(key: "sleeves", labelEn: "Sleeves", labelUr: "آستین"),
    MeasurementFieldDef(key: "waist", labelEn: "Waist", labelUr: "کمر"),
    MeasurementFieldDef(key: "trouser_length", labelEn: "Trouser Length", labelUr: "پتلون لمبائی"),
    MeasurementFieldDef(key: "trouser_bottom", labelEn: "Trouser Bottom", labelUr: "پتلون موہری"),
    MeasurementFieldDef(key: "inseam", labelEn: "Inseam", labelUr: "اندرونی لمبائی"),
  ];

  // ── Kurta ──
  static const List<MeasurementFieldDef> _kurta = [
    MeasurementFieldDef(key: "length", labelEn: "Length", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "chest", labelEn: "Chest", labelUr: "سینہ"),
    MeasurementFieldDef(key: "shoulder", labelEn: "Shoulder", labelUr: "کندھا"),
    MeasurementFieldDef(key: "sleeves", labelEn: "Sleeves", labelUr: "آستین"),
    MeasurementFieldDef(key: "collar", labelEn: "Collar", labelUr: "گلا"),
    MeasurementFieldDef(key: "daman", labelEn: "Daman", labelUr: "دامن"),
  ];

  // ── Waistcoat ──
  static const List<MeasurementFieldDef> _waistcoat = [
    MeasurementFieldDef(key: "length", labelEn: "Length", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "chest", labelEn: "Chest", labelUr: "سینہ"),
    MeasurementFieldDef(key: "shoulder", labelEn: "Shoulder", labelUr: "کندھا"),
  ];

  // ── Pants ──
  static const List<MeasurementFieldDef> _pants = [
    MeasurementFieldDef(key: "length", labelEn: "Length", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "waist", labelEn: "Waist", labelUr: "کمر"),
    MeasurementFieldDef(key: "hip", labelEn: "Hip", labelUr: "کولہا"),
    MeasurementFieldDef(key: "thigh", labelEn: "Thigh", labelUr: "ران"),
    MeasurementFieldDef(key: "bottom", labelEn: "Bottom", labelUr: "موہری"),
    MeasurementFieldDef(key: "inseam", labelEn: "Inseam", labelUr: "اندرونی لمبائی"),
  ];

  // ── Shirt ──
  static const List<MeasurementFieldDef> _shirt = [
    MeasurementFieldDef(key: "length", labelEn: "Length", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "chest", labelEn: "Chest", labelUr: "سینہ"),
    MeasurementFieldDef(key: "shoulder", labelEn: "Shoulder", labelUr: "کندھا"),
    MeasurementFieldDef(key: "sleeves", labelEn: "Sleeves", labelUr: "آستین"),
    MeasurementFieldDef(key: "collar", labelEn: "Collar", labelUr: "گلا"),
    MeasurementFieldDef(key: "cuff", labelEn: "Cuff", labelUr: "کف"),
  ];

  // ── Women's Dress ──
  static const List<MeasurementFieldDef> _womensDress = [
    MeasurementFieldDef(key: "length", labelEn: "Length", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "chest", labelEn: "Chest", labelUr: "سینہ"),
    MeasurementFieldDef(key: "waist", labelEn: "Waist", labelUr: "کمر"),
    MeasurementFieldDef(key: "hip", labelEn: "Hip", labelUr: "کولہا"),
    MeasurementFieldDef(key: "shoulder", labelEn: "Shoulder", labelUr: "کندھا"),
    MeasurementFieldDef(key: "sleeves", labelEn: "Sleeves", labelUr: "آستین"),
    MeasurementFieldDef(key: "armhole", labelEn: "Armhole", labelUr: "بغل"),
    MeasurementFieldDef(key: "daman", labelEn: "Daman", labelUr: "دامن"),
  ];
}

class MeasurementFieldDef {
  final String key;
  final String labelEn;
  final String labelUr;

  const MeasurementFieldDef({
    required this.key,
    required this.labelEn,
    required this.labelUr,
  });
}
