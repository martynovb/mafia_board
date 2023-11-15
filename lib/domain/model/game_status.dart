enum GameStatus { notStarted, inProgress, finished, none }

GameStatus gameStatusMapper(String? status) {
  if (status == GameStatus.notStarted.name) {
    return GameStatus.notStarted;
  } else if (status == GameStatus.inProgress.name) {
    return GameStatus.inProgress;
  } else if (status == GameStatus.finished.name) {
    return GameStatus.finished;
  } else {
    return GameStatus.none;
  }
}
