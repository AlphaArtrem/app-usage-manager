String formatTime(double seconds){
  int buffer = seconds ~/ (60 * 60);
  seconds = seconds % (60 * 60);
  String time = buffer.toString().length == 1 ? '0' + buffer.toString() + ':' : buffer.toString() + ':';
  buffer = seconds ~/ (60);
  seconds = seconds % (60);
  time += buffer.toString().length == 1 ? '0' + buffer.toString() + ':' : buffer.toString() + ':';
  buffer = seconds.toInt();
  time += buffer.toString().length == 1 ? '0' + buffer.toString() : buffer.toString();

  return time;
}