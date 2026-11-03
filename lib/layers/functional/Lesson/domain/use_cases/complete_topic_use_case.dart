import '../gateways/progress_gateway.dart';

class CompleteTopicUseCase {
  const CompleteTopicUseCase(this._progressGateway);

  final ProgressGateway _progressGateway;

  Future<Set<String>> call(String topicId) async {
    await _progressGateway.markCompleted(topicId);
    return _progressGateway.readCompletedTopicIds();
  }
}
