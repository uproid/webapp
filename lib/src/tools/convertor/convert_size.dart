class ConvertSize {
  static String toLogicSizeString(int fileSizeInBytes) {
    if (fileSizeInBytes < 1024) {
      return '$fileSizeInBytes B';
    } else if (fileSizeInBytes < 1024 * 1024) {
      double fileSizeInKB = fileSizeInBytes / 1024;
      return '${fileSizeInKB.toStringAsFixed(2)} KB';
    } else if (fileSizeInBytes < 1024 * 1024 * 1024) {
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      return '${fileSizeInMB.toStringAsFixed(2)} MB';
    } else {
      double fileSizeInGB = fileSizeInBytes / (1024 * 1024 * 1024);
      return '${fileSizeInGB.toStringAsFixed(2)} GB';
    }
  }
}
