T? tryCast<T>(Object? x) => x is T ? x : null;

// ignore: avoid_annotating_with_dynamic
Map<String, dynamic>? tryCastMap<T>(dynamic x) =>
    x is Map ? Map.castFrom<dynamic, dynamic, String, dynamic>(x) : null;
