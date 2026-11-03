import '../../domain/entities/topic.dart';
import '../../domain/gateways/topic_gateway.dart';
import '../data_sources/topic_asset_data_source.dart';

class AssetTopicGateway implements TopicGateway {
  const AssetTopicGateway(this._dataSource);

  final TopicAssetDataSource _dataSource;

  @override
  Future<List<Topic>> loadAll() async {
    final batches = await _dataSource.readBatches();
    final topics = <Topic>[];
    final seenIds = <String>{};
    final longest = batches.fold<int>(0, (max, batch) => batch.length > max ? batch.length : max);
    for (var row = 0; row < longest; row++) {
      for (final batch in batches) {
        if (row >= batch.length || !batch[row].isValid) {
          continue;
        }
        final topic = batch[row].toEntity();
        if (seenIds.add(topic.id)) {
          topics.add(topic);
        }
      }
    }
    return topics;
  }
}
