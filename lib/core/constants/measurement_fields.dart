class MeasurementFields {
  MeasurementFields._();

  /// Garment chips shown in Naap Book (matches Darzi mockup).
  static const Map<String, List<MeasurementFieldDef>> categories = {
    "shalwar_kameez": _shalwarKameez,
    "kurta": _kurta,
    "waistcoat": _waistcoat,
    "pant_shirt": _pantShirt,
    "mens_suit": _mensSuit,
    "womens_dress": _womensDress,
  };

  static const Map<String, String> categoryLabelsEn = {
    "shalwar_kameez": "Shalwar Kameez",
    "kurta": "Kurta",
    "waistcoat": "Waistcoat",
    "pant_shirt": "Pant-shirt",
    "mens_suit": "Men's Suit",
    "womens_dress": "Ladies suit",
  };

  static const Map<String, String> categoryLabelsUr = {
    "shalwar_kameez": "شلوار قمیض",
    "kurta": "کرتا",
    "waistcoat": "واسکٹ",
    "pant_shirt": "پینٹ شرٹ",
    "mens_suit": "مردانہ سوٹ",
    "womens_dress": "لیڈیز سوٹ",
  };

  /// Primary chips in mockup order (first 4).
  static const List<String> primaryCategories = [
    "shalwar_kameez",
    "kurta",
    "waistcoat",
    "pant_shirt",
  ];

  // ── Shalwar Kameez (mockup: Lambai · Baazu · Tera · Chaati · Kamar · Gher · Gala · Shalwar)
  static const List<MeasurementFieldDef> _shalwarKameez = [
    MeasurementFieldDef(key: "lambai", labelEn: "Lambai", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "baazu", labelEn: "Baazu", labelUr: "بازو"),
    MeasurementFieldDef(key: "tera", labelEn: "Tera", labelUr: "کندھا"),
    MeasurementFieldDef(key: "chaati", labelEn: "Chaati", labelUr: "چھاتی"),
    MeasurementFieldDef(key: "kamar", labelEn: "Kamar", labelUr: "کمر"),
    MeasurementFieldDef(key: "gher", labelEn: "Gher", labelUr: "گھیر"),
    MeasurementFieldDef(key: "gala", labelEn: "Gala", labelUr: "گلا"),
    MeasurementFieldDef(key: "shalwar", labelEn: "Shalwar", labelUr: "شلوار"),
  ];

  // ── Kurta ──
  static const List<MeasurementFieldDef> _kurta = [
    MeasurementFieldDef(key: "lambai", labelEn: "Lambai", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "chaati", labelEn: "Chaati", labelUr: "چھاتی"),
    MeasurementFieldDef(key: "tera", labelEn: "Tera", labelUr: "کندھا"),
    MeasurementFieldDef(key: "baazu", labelEn: "Baazu", labelUr: "بازو"),
    MeasurementFieldDef(key: "gala", labelEn: "Gala", labelUr: "گلا"),
    MeasurementFieldDef(key: "gher", labelEn: "Gher", labelUr: "گھیر"),
  ];

  // ── Waistcoat ──
  static const List<MeasurementFieldDef> _waistcoat = [
    MeasurementFieldDef(key: "lambai", labelEn: "Lambai", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "chaati", labelEn: "Chaati", labelUr: "چھاتی"),
    MeasurementFieldDef(key: "tera", labelEn: "Tera", labelUr: "کندھا"),
    MeasurementFieldDef(key: "kamar", labelEn: "Kamar", labelUr: "کمر"),
  ];

  // ── Pant-shirt ──
  static const List<MeasurementFieldDef> _pantShirt = [
    MeasurementFieldDef(key: "shirt_lambai", labelEn: "Shirt", labelUr: "شرٹ"),
    MeasurementFieldDef(key: "chaati", labelEn: "Chaati", labelUr: "چھاتی"),
    MeasurementFieldDef(key: "tera", labelEn: "Tera", labelUr: "کندھا"),
    MeasurementFieldDef(key: "baazu", labelEn: "Baazu", labelUr: "بازو"),
    MeasurementFieldDef(key: "gala", labelEn: "Gala", labelUr: "گلا"),
    MeasurementFieldDef(key: "pant_lambai", labelEn: "Pant", labelUr: "پینٹ"),
    MeasurementFieldDef(key: "kamar", labelEn: "Kamar", labelUr: "کمر"),
    MeasurementFieldDef(key: "hip", labelEn: "Hip", labelUr: "کولہا"),
  ];

  // ── Men's Suit ──
  static const List<MeasurementFieldDef> _mensSuit = [
    MeasurementFieldDef(key: "coat_lambai", labelEn: "Coat", labelUr: "کوٹ"),
    MeasurementFieldDef(key: "chaati", labelEn: "Chaati", labelUr: "چھاتی"),
    MeasurementFieldDef(key: "tera", labelEn: "Tera", labelUr: "کندھا"),
    MeasurementFieldDef(key: "baazu", labelEn: "Baazu", labelUr: "بازو"),
    MeasurementFieldDef(key: "kamar", labelEn: "Kamar", labelUr: "کمر"),
    MeasurementFieldDef(key: "pant_lambai", labelEn: "Pant", labelUr: "پینٹ"),
    MeasurementFieldDef(key: "bottom", labelEn: "Bottom", labelUr: "موہری"),
    MeasurementFieldDef(key: "inseam", labelEn: "Inseam", labelUr: "اندرونی"),
  ];

  // ── Ladies suit ──
  static const List<MeasurementFieldDef> _womensDress = [
    MeasurementFieldDef(key: "lambai", labelEn: "Lambai", labelUr: "لمبائی"),
    MeasurementFieldDef(key: "chaati", labelEn: "Chaati", labelUr: "چھاتی"),
    MeasurementFieldDef(key: "kamar", labelEn: "Kamar", labelUr: "کمر"),
    MeasurementFieldDef(key: "hip", labelEn: "Hip", labelUr: "کولہا"),
    MeasurementFieldDef(key: "tera", labelEn: "Tera", labelUr: "کندھا"),
    MeasurementFieldDef(key: "baazu", labelEn: "Baazu", labelUr: "بازو"),
    MeasurementFieldDef(key: "gher", labelEn: "Gher", labelUr: "گھیر"),
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
