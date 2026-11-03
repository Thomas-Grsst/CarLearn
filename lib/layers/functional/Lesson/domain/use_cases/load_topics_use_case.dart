import '../entities/topic.dart';
import '../gateways/topic_gateway.dart';

class LoadTopicsUseCase {
  const LoadTopicsUseCase(this._topicGateway);

  final TopicGateway _topicGateway;

  Future<List<Topic>> call() => _topicGateway.loadAll();
}
