import 'package:flutter/widgets.dart';

enum ResultType { TYPE_A, TYPE_B, TYPE_C }

class Service {
  static Future<Map<ResultType, List<Result>>> getResults() {
    List<Result> typeAResults = [
      Result(ResultType.TYPE_A, "First Type A Result"),
      Result(ResultType.TYPE_A, "Second Type A Result"),
      Result(ResultType.TYPE_A, "Third Type A Result"),
    ];
    List<Result> typeBResults = [
      Result(ResultType.TYPE_B, "First Type B Result"),
      Result(ResultType.TYPE_B, "Second Type B Result"),
      Result(ResultType.TYPE_B, "Third Type B Result"),
    ];
    List<Result> typeCResults = [
      Result(ResultType.TYPE_C, "First Type C Result"),
      Result(ResultType.TYPE_C, "Second Type C Result"),
      Result(ResultType.TYPE_C, "Thrid Type C Result"),
    ];

    Future.delayed(Duration(seconds: 1));

    return Future.value({
      ResultType.TYPE_A: typeAResults,
      ResultType.TYPE_B: typeBResults,
      ResultType.TYPE_C: typeCResults
    });
  }
}

class Result {
  ResultType rType;
  String resultData;
  Result(this.rType, this.resultData);
}
