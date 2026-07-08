String medicationText(dynamic value, {String fallback = '-'}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
  return text;
}

String normalizeMedicationDose(dynamic value, {dynamic form}) {
  var text = medicationText(value);
  final formText = medicationText(form, fallback: '');

  if (text == '-') return text;

  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  text = text.replaceAllMapped(
    RegExp(r'\b(\d+)\.00\b'),
    (match) => match.group(1) ?? match.group(0)!,
  );
  text = text.replaceAllMapped(
    RegExp(r'\b(\d+\.\d*?[1-9])0+\b'),
    (match) => match.group(1) ?? match.group(0)!,
  );

  // Backend lama pernah membentuk teks seperti "500.00 500mg Tablet".
  // Kalau angka pertama hanya duplikasi dari angka kedua, pakai bagian kedua saja.
  final duplicated = RegExp(
    r'^(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?\s*[^\s].*)$',
    caseSensitive: false,
  ).firstMatch(text);
  if (duplicated != null) {
    final first = double.tryParse(duplicated.group(1) ?? '');
    final rest = duplicated.group(2) ?? '';
    final secondMatch = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(rest.trim());
    final second = double.tryParse(secondMatch?.group(1) ?? '');
    if (first != null && second != null && first == second) {
      text = rest.trim();
    }
  }

  text = text.replaceAllMapped(
    RegExp(r'(\d)(mg|g|gram|ml|mL|mcg|µg|ug|iu|IU|unit|tablet|kapsul|tetes)\b'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (formText.isNotEmpty) {
    final escapedForm = RegExp.escape(formText);
    final formAtEnd = RegExp(
      r'\s+' + escapedForm + r'$',
      caseSensitive: false,
    );

    // Kalau teks sudah punya dosis + satuan obat + bentuk sediaan di belakang,
    // pisahkan bentuknya. Contoh: "500 mg Tablet" -> "500 mg".
    // Tapi "1 Tablet" tetap dibiarkan karena Tablet adalah satuannya.
    final withoutForm = text.replaceAll(formAtEnd, '').trim();
    final hasDrugUnit = RegExp(
      r'(^|\s)(mg|g|gram|ml|mL|mcg|µg|ug|iu|IU|unit)(\s|$)',
      caseSensitive: false,
    ).hasMatch(withoutForm);

    if (formAtEnd.hasMatch(text) && hasDrugUnit) {
      text = withoutForm;
    }
  }

  return text.isEmpty ? '-' : text;
}

bool doseContainsForm(String dose, String form) {
  if (dose.trim().isEmpty || form.trim().isEmpty || dose == '-') return false;
  return RegExp(
    r'(^|\s)' + RegExp.escape(form.trim()) + r'(\s|$)',
    caseSensitive: false,
  ).hasMatch(dose);
}

String medicationDoseLine({
  dynamic dosage,
  dynamic dosePerSession,
  dynamic form,
}) {
  final formText = medicationText(form, fallback: '');
  final doseFromSchedule = normalizeMedicationDose(
    dosePerSession,
    form: formText,
  );
  final doseFromPrescription = normalizeMedicationDose(
    dosage,
    form: formText,
  );

  final dose = doseFromSchedule != '-' ? doseFromSchedule : doseFromPrescription;
  final parts = <String>[];

  if (dose != '-') parts.add(dose);
  if (formText.isNotEmpty && formText != '-' && !doseContainsForm(dose, formText)) {
    parts.add(formText);
  }

  return parts.isEmpty ? '-' : parts.join(' • ');
}
