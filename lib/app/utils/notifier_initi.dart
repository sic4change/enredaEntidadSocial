import 'package:flutter/material.dart';

class NotifierInit<T> {
  final ValueNotifier<List<T>> notifier;
  bool initialized = false;

  NotifierInit(List<T> initial)
      : notifier = ValueNotifier<List<T>>(initial);

  void initOnce(List<T>? data, {List<T>? fallback}) {
    if (!initialized) {
      notifier.value = (data == null || data.isEmpty)
          ? (fallback ?? [])
          : data;
      initialized = true;
    }
  }
}
