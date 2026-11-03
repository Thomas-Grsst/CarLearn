import '../entities/topic.dart';

abstract interface class TopicGateway {
  Future<List<Topic>> loadAll();
}
