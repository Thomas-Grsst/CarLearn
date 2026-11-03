import '../entities/saved_position.dart';
import '../gateways/progress_gateway.dart';

class ReadPositionUseCase {
  const ReadPositionUseCase(this._progressGateway);

  final ProgressGateway _progressGateway;

  Future<SavedPosition?> call() => _progressGateway.readPosition();
}
