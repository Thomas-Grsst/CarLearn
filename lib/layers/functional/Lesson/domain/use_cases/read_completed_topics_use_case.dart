import '../gateways/progress_gateway.dart';

class ReadCompletedTopicsUseCase {
  const ReadCompletedTopicsUseCase(this._progressGateway);

  final ProgressGateway _progressGateway;

  Future<Set<String>> call() => _progressGateway.readCompletedTopicIds();
}
