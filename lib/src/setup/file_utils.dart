import 'dart:io';

/// 安全文件操作工具
/// 
/// 提供文件备份、还原、安全修改等功能，确保配置过程的安全性
class FileUtils {
  static const String _backupSuffix = '.wsd_backup';
  
  /// 创建文件备份
  static Future<bool> createBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('⚠️  文件不存在，跳过备份: $filePath');
        return true;
      }
      
      final backupPath = '$filePath$_backupSuffix';
      await file.copy(backupPath);
      print('📦 已创建备份: $backupPath');
      return true;
    } catch (e) {
      print('❌ 创建备份失败: $filePath - $e');
      return false;
    }
  }
  
  /// 还原文件备份
  static Future<bool> restoreBackup(String filePath) async {
    try {
      final backupPath = '$filePath$_backupSuffix';
      final backupFile = File(backupPath);
      
      if (!backupFile.existsSync()) {
        print('⚠️  备份文件不存在: $backupPath');
        return false;
      }
      
      await backupFile.copy(filePath);
      print('🔄 已还原备份: $filePath');
      return true;
    } catch (e) {
      print('❌ 还原备份失败: $filePath - $e');
      return false;
    }
  }
  
  /// 删除备份文件
  static Future<bool> removeBackup(String filePath) async {
    try {
      final backupPath = '$filePath$_backupSuffix';
      final backupFile = File(backupPath);
      
      if (backupFile.existsSync()) {
        await backupFile.delete();
        print('🗑️  已删除备份: $backupPath');
      }
      return true;
    } catch (e) {
      print('❌ 删除备份失败: $filePath - $e');
      return false;
    }
  }
  
  /// 检查备份是否存在
  static bool hasBackup(String filePath) {
    return File('$filePath$_backupSuffix').existsSync();
  }
  
  /// 安全地读取文件内容
  static Future<String?> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('⚠️  文件不存在: $filePath');
        return null;
      }
      return await file.readAsString();
    } catch (e) {
      print('❌ 读取文件失败: $filePath - $e');
      return null;
    }
  }
  
  /// 安全地写入文件内容
  static Future<bool> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      
      // 确保目录存在
      await file.parent.create(recursive: true);
      
      await file.writeAsString(content);
      print('✅ 文件写入成功: $filePath');
      return true;
    } catch (e) {
      print('❌ 文件写入失败: $filePath - $e');
      return false;
    }
  }
  
  /// 在文件中查找并替换内容
  static Future<bool> replaceInFile(String filePath, String pattern, String replacement) async {
    final content = await readFile(filePath);
    if (content == null) return false;
    
    if (!content.contains(pattern)) {
      print('⚠️  未找到要替换的内容: $pattern');
      return false;
    }
    
    final newContent = content.replaceAll(pattern, replacement);
    return await writeFile(filePath, newContent);
  }
  
  /// 在文件末尾追加内容
  static Future<bool> appendToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content, mode: FileMode.append);
      print('✅ 内容追加成功: $filePath');
      return true;
    } catch (e) {
      print('❌ 内容追加失败: $filePath - $e');
      return false;
    }
  }
  
  /// 在指定位置插入内容
  static Future<bool> insertInFile(String filePath, String marker, String content, {bool after = true}) async {
    final originalContent = await readFile(filePath);
    if (originalContent == null) return false;
    
    if (!originalContent.contains(marker)) {
      print('⚠️  未找到插入标记: $marker');
      return false;
    }
    
    String newContent;
    if (after) {
      newContent = originalContent.replaceFirst(marker, '$marker\n$content');
    } else {
      newContent = originalContent.replaceFirst(marker, '$content\n$marker');
    }
    
    return await writeFile(filePath, newContent);
  }
  
  /// 创建目录
  static Future<bool> createDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
        print('📁 创建目录: $dirPath');
      }
      return true;
    } catch (e) {
      print('❌ 创建目录失败: $dirPath - $e');
      return false;
    }
  }
  
  /// 确保文件存在，如不存在则创建
  static Future<bool> ensureFileExists(String filePath, {String defaultContent = ''}) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      await createDirectory(file.parent.path);
      return await writeFile(filePath, defaultContent);
    }
    return true;
  }
  
  /// 检查文件是否包含指定内容
  static Future<bool> fileContains(String filePath, String content) async {
    final fileContent = await readFile(filePath);
    return fileContent?.contains(content) ?? false;
  }
  
  /// 格式化路径
  static String normalizePath(String path) {
    return path.replaceAll('\\', '/');
  }
  
  /// 获取相对路径
  static String getRelativePath(String basePath, String targetPath) {
    final base = normalizePath(basePath);
    final target = normalizePath(targetPath);
    
    if (target.startsWith(base)) {
      return target.substring(base.length + 1);
    }
    return target;
  }
}

/// 文件操作结果类
class FileOperationResult {
  final bool success;
  final String? message;
  final String? error;
  
  FileOperationResult.success([this.message]) 
      : success = true, error = null;
  
  FileOperationResult.failure(this.error, [this.message]) 
      : success = false;
  
  void printResult() {
    if (success) {
      print('✅ ${message ?? "操作成功"}');
    } else {
      print('❌ ${message ?? "操作失败"}: $error');
    }
  }
} 