class TextUtils {
  static final Map<String, String> _vietnameseMap = {
    'àáạảãâầấậẩẫăằắặẳẵ': 'a',
    'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ': 'A',
    'èéẹẻẽêềếệểễ': 'e',
    'ÈÉẸẺẼÊỀẾỆỂỄ': 'E',
    'ìíịỉĩ': 'i',
    'ÌÍỊỈĨ': 'I',
    'òóọỏõôồốộổỗơờớợởỡ': 'o',
    'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ': 'O',
    'ùúụủũưừứựửữ': 'u',
    'ÙÚỤỦŨƯỪỨỰỬỮ': 'U',
    'ỳýỵỷỹ': 'y',
    'ỲÝỴỶỸ': 'Y',
    'đ': 'd',
    'Đ': 'D',
  };

  static String removeDiacritics(String input) {
    var s = input;
    _vietnameseMap.forEach((chars, base) {
      for (var i = 0; i < chars.length; i++) {
        s = s.replaceAll(chars[i], base);
      }
    });
    return s;
  }

  static String normalizeForSearch(String input) {
    return removeDiacritics(input).toLowerCase().trim();
  }

  static bool _hasDiacritics(String input) {
    return removeDiacritics(input) != input;
  }

  static bool containsQuery({required String text, required String query}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    if (_hasDiacritics(q)) {
      return text.toLowerCase().contains(q);
    }

    final nText = normalizeForSearch(text);
    final nQuery = normalizeForSearch(q);
    return nText.contains(nQuery);
  }
}
