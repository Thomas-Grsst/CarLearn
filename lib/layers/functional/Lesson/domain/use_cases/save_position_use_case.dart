import '../entities/saved_position.dart';
import '../gateways/progress_gateway.dart';

class SavePositionUseCase {
  const SavePositionUseCase(this._progressGateway);

  final ProgressGateway _progressGateway;

  Future<void> call(SavedPosition position) => _progressGateway.writePosition(position);
}
