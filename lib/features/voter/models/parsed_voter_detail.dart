class ParsedVoterData {
  final String voterName;
  final String epicNumber;
  final String address;
  final String serialNumber;
  final String partNumberAndName;
  final String constituencyName;
  final String stateName;
  final String phoneNumber;
  final String rawCleanedText;

  const ParsedVoterData({
    this.voterName = '',
    this.epicNumber = '',
    this.address = '',
    this.serialNumber = '',
    this.partNumberAndName = '',
    this.constituencyName = '',
    this.stateName = '',
    this.phoneNumber = '',
    this.rawCleanedText = '',
  });

  int get filledCount => [
    voterName,
    epicNumber,
    address,
    serialNumber,
    partNumberAndName,
    constituencyName,
    stateName,
    phoneNumber,
  ].where((e) => e.trim().isNotEmpty).length;

  ParsedVoterData copyWith({
    String? voterName,
    String? epicNumber,
    String? address,
    String? serialNumber,
    String? partNumberAndName,
    String? constituencyName,
    String? stateName,
    String? phoneNumber,
    String? rawCleanedText,
  }) {
    return ParsedVoterData(
      voterName: voterName ?? this.voterName,
      epicNumber: epicNumber ?? this.epicNumber,
      address: address ?? this.address,
      serialNumber: serialNumber ?? this.serialNumber,
      partNumberAndName: partNumberAndName ?? this.partNumberAndName,
      constituencyName: constituencyName ?? this.constituencyName,
      stateName: stateName ?? this.stateName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rawCleanedText: rawCleanedText ?? this.rawCleanedText,
    );
  }

  static ParsedVoterData parse(String rawText) {
    final cleaned = cleanOcrText(rawText);

    String voterName = '';
    String epicNumber = '';
    String address = '';
    String serialNumber = '';
    String partNumberAndName = '';
    String constituencyName = '';
    String stateName = '';
    String phoneNumber = '';

    final lines = cleaned
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      if (voterName.isEmpty &&
          (line.contains('निर्वाचक का नाम') ||
              lower.contains('voter name') ||
              lower.contains('name of elector'))) {
        voterName = _extractMultilineField(lines, i);
      }

      if (epicNumber.isEmpty &&
          (line.contains('ईपीआईसी') ||
              lower.contains('epic') ||
              lower.contains('epic number'))) {
        epicNumber = _extractEpic(_extractMultilineField(lines, i));
      }

      if (address.isEmpty &&
          (line.contains('पता') || lower.startsWith('address'))) {
        address = _extractMultilineField(lines, i);
      }

      if (serialNumber.isEmpty &&
          (line.contains('क्रम संख्या') ||
              lower.contains('serial number') ||
              lower.contains('serial no'))) {
        serialNumber = _extractValueAfterColon(line);
      }

      if (partNumberAndName.isEmpty &&
          (line.contains('भाग संख्या') ||
              line.contains('भाग का नाम') ||
              lower.contains('part number') ||
              lower.contains('part name'))) {
        partNumberAndName = _extractMultilineField(lines, i);
      }

      if (constituencyName.isEmpty &&
          (line.contains('विधानसभा') ||
              line.contains('संसदीय निर्वाचन क्षेत्र') ||
              lower.contains('constituency'))) {
        constituencyName = _extractMultilineField(lines, i);
      }

      if (stateName.isEmpty &&
          (line.contains('राज्य') || lower.contains('state'))) {
        stateName = _extractMultilineField(lines, i);
      }

      if (phoneNumber.isEmpty &&
          (line.contains('मोबाइल') ||
              line.contains('मोबाइल नंबर') ||
              line.contains('फोन') ||
              lower.contains('mobile') ||
              lower.contains('phone'))) {
        phoneNumber = normalizePhoneNumber(_extractMultilineField(lines, i));
      }
    }

    final fullText = cleaned;

    if (voterName.isEmpty) {
      voterName = _extractNameFallback(fullText);
    }

    if (epicNumber.isEmpty) {
      epicNumber = _extractEpic(fullText);
    }

    if (serialNumber.isEmpty) {
      serialNumber = _extractSerialFallback(fullText);
    }

    if (partNumberAndName.isEmpty) {
      partNumberAndName = _extractPartFallback(fullText);
    }

    if (constituencyName.isEmpty) {
      constituencyName = _extractConstituencyFallback(fullText);
    }

    if (address.isEmpty) {
      address = _extractAddressFallback(fullText);
    }

    if (stateName.isEmpty && fullText.contains('उत्तर प्रदेश')) {
      stateName = 'उत्तर प्रदेश';
    }

    if (phoneNumber.isEmpty) {
      phoneNumber = normalizePhoneNumber(fullText);
    }

    voterName = _cleanFieldValue(voterName);
    epicNumber = _extractEpic(epicNumber);
    address = _cleanFieldValue(address);
    serialNumber = _cleanFieldValue(serialNumber);
    partNumberAndName = _cleanFieldValue(partNumberAndName);
    constituencyName = _cleanFieldValue(constituencyName);
    stateName = _cleanFieldValue(stateName);
    phoneNumber = normalizePhoneNumber(phoneNumber);

    return ParsedVoterData(
      voterName: voterName,
      epicNumber: epicNumber,
      address: address,
      serialNumber: serialNumber,
      partNumberAndName: partNumberAndName,
      constituencyName: constituencyName,
      stateName: stateName,
      phoneNumber: phoneNumber,
      rawCleanedText: cleaned,
    );
  }

  static String cleanOcrText(String text) {
    var cleaned = text;

    cleaned = cleaned.replaceAll(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      '\n',
    );
    cleaned = cleaned.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    cleaned = cleaned.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
    cleaned = cleaned.replaceAll(RegExp(r'</td>', caseSensitive: false), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'</tr>', caseSensitive: false), '\n');

    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');

    cleaned = cleaned.replaceAll('&nbsp;', ' ');
    cleaned = cleaned.replaceAll('&amp;', '&');
    cleaned = cleaned.replaceAll('&lt;', '<');
    cleaned = cleaned.replaceAll('&gt;', '>');
    cleaned = cleaned.replaceAll('&quot;', '"');
    cleaned = cleaned.replaceAll('&#39;', "'");
    cleaned = cleaned.replaceAll('\r', '\n');

    cleaned = cleaned.replaceAll(RegExp(r'[ \t]+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n+'), '\n');

    return cleaned.trim();
  }

  static String normalizePhoneNumber(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  static String _extractValueAfterColon(String text) {
    final idx = text.indexOf(':');
    if (idx == -1) return text.trim();
    return text.substring(idx + 1).trim();
  }

  static String _extractEpic(String text) {
    final match = RegExp(r'[A-Z]{3}[0-9]{7}').firstMatch(text);
    return match?.group(0) ?? '';
  }

  static String _extractMultilineField(List<String> lines, int startIndex) {
    String value = _extractValueAfterColon(lines[startIndex]);

    for (int j = startIndex + 1; j < lines.length; j++) {
      final nextLine = lines[j].trim();
      if (nextLine.isEmpty) continue;

      if (_looksLikeNewFieldLabel(nextLine)) {
        break;
      }

      value = '$value $nextLine';
    }

    return value.trim();
  }

  static bool _looksLikeNewFieldLabel(String line) {
    final lower = line.toLowerCase();

    final labels = [
      'निर्वाचक का नाम',
      'नाम',
      'ईपीआईसी',
      'epic',
      'पता',
      'address',
      'क्रम संख्या',
      'serial number',
      'serial no',
      'भाग संख्या',
      'भाग का नाम',
      'part number',
      'part name',
      'विधानसभा',
      'संसदीय निर्वाचन क्षेत्र',
      'निर्वाचन क्षेत्र का नाम',
      'constituency',
      'राज्य',
      'state',
      'मोबाइल',
      'मोबाइल नंबर',
      'फोन',
      'mobile',
      'phone',
    ];

    for (final label in labels) {
      if (line.contains(label) || lower.contains(label.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  static String _cleanFieldValue(String value) {
    var v = value.trim();
    v = v.replaceAll(RegExp(r'\s+'), ' ');

    final prefixes = [
      RegExp(r'^निर्वाचक का नाम[:\s]*'),
      RegExp(r'^नाम[:\s]*'),
      RegExp(r'^ईपीआईसी[:\s]*'),
      RegExp(r'^epic[:\s]*', caseSensitive: false),
      RegExp(r'^पता[:\s]*'),
      RegExp(r'^address[:\s]*', caseSensitive: false),
      RegExp(r'^क्रम संख्या[:\s]*'),
      RegExp(r'^भाग संख्या एवं नाम[:\s]*'),
      RegExp(r'^भाग संख्या[:\s]*'),
      RegExp(r'^भाग का नाम[:\s]*'),
      RegExp(r'^विधानसभा\s*/\s*संसदीय निर्वाचन क्षेत्र का नाम[:\s]*'),
      RegExp(r'^विधानसभा[:\s]*'),
      RegExp(r'^राज्य का नाम[:\s]*'),
      RegExp(r'^राज्य[:\s]*'),
      RegExp(r'^मोबाइल नंबर[:\s]*'),
      RegExp(r'^मोबाइल[:\s]*'),
      RegExp(r'^फोन[:\s]*'),
      RegExp(r'^mobile number[:\s]*', caseSensitive: false),
      RegExp(r'^mobile[:\s]*', caseSensitive: false),
      RegExp(r'^phone[:\s]*', caseSensitive: false),
    ];

    for (final prefix in prefixes) {
      v = v.replaceFirst(prefix, '').trim();
    }

    return v;
  }

  static String _extractNameFallback(String text) {
    final patterns = [
      RegExp(r'निर्वाचक का नाम[:\s]+([^\n]+)'),
      RegExp(r'नाम[:\s]+([^\n]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final value = match.group(1)?.trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }
    return '';
  }

  static String _extractSerialFallback(String text) {
    final patterns = [
      RegExp(r'क्रम संख्या[:\s]+([0-9]+)'),
      RegExp(r'serial number[:\s]+([0-9]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    return '';
  }

  static String _extractPartFallback(String text) {
    final patterns = [
      RegExp(
        r'भाग\s*संख्या\s*एवं\s*नाम[:\s]*(.+?)(?:\n(?:विधानसभा|संसदीय|राज्य|क्रम\s*संख्या|ईपीआईसी|निर्वाचक|मोबाइल|फोन)|$)',
        caseSensitive: false,
        dotAll: true,
      ),
      RegExp(
        r'भाग\s*संख्या[:\s]*(.+?)(?:\n(?:विधानसभा|संसदीय|राज्य|क्रम\s*संख्या|ईपीआईसी|निर्वाचक|मोबाइल|फोन)|$)',
        caseSensitive: false,
        dotAll: true,
      ),
      RegExp(
        r'part\s*number.*?[:\s]*(.+?)(?:\n(?:assembly|constituency|state|serial|mobile|phone)|$)',
        caseSensitive: false,
        dotAll: true,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final value = match.group(1)?.trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }
    return '';
  }

  static String _extractConstituencyFallback(String text) {
    final patterns = [
      RegExp(r'निर्वाचन क्षेत्र का नाम[:\s]+([^\n]+)'),
      RegExp(r'विधानसभा.*?[:\s]+([^\n]+)'),
      RegExp(r'constituency.*?[:\s]+([^\n]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    return '';
  }

  static String _extractAddressFallback(String text) {
    final lines = text.split('\n').map((e) => e.trim()).toList();

    final buffer = <String>[];
    bool started = false;

    for (final line in lines) {
      if (!started &&
          (line.startsWith('पता:') ||
              line.startsWith('पता :') ||
              line.toLowerCase().startsWith('address:'))) {
        started = true;
        buffer.add(_extractValueAfterColon(line));
        continue;
      }

      if (started) {
        if (_looksLikeNewFieldLabel(line)) break;
        buffer.add(line);
      }
    }

    if (buffer.isNotEmpty) {
      return buffer.join(' ').trim();
    }

    for (final line in lines) {
      if ((line.contains('उत्तर प्रदेश') ||
              RegExp(r'\b\d{6}\b').hasMatch(line) ||
              line.contains('लखनऊ')) &&
          !line.contains('ईपीआईसी') &&
          !line.contains('भाग संख्या') &&
          !line.contains('निर्वाचक का नाम')) {
        return line.trim();
      }
    }

    return '';
  }
}
