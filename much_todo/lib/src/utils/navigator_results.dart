class CompleteTaskResult {
  bool shouldComplete;
  DateTime? completionDate;
  double? cost;

  CompleteTaskResult({required this.shouldComplete, required this.completionDate, this.cost});
}
