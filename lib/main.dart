import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IP PBX建議錄音天數計算',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Controllers for input fields
  final TextEditingController customStorageController = TextEditingController();
  final TextEditingController phoneCountController = TextEditingController();
  final TextEditingController recordDaysController = TextEditingController();
  final TextEditingController dailyCallController = TextEditingController();
  final TextEditingController monthlyCallController = TextEditingController();
  final TextEditingController recordingCapacityController = TextEditingController();
  final TextEditingController recommendedStorageController = TextEditingController();
  final TextEditingController notificationController = TextEditingController();

  // State variables
  String? audioFormat;
  String? storageType;
  String? pbxSpec;
  String? companyType;
  bool isCalculated = false;
  bool needsRecalculation = false;

  // Calculated values
  double actualUsableCapacity = 0.0;
  double actualRecordingCapacity = 0.0;
  String dailyCallDuration = '';
  String monthlyCallSeconds = '';
  String recordingCapacity = '';
  String recommendedStorage = '';

  // PBX specifications mapping
  Map<String, Map<String, dynamic>> pbxSpecs = {
    '10/60': {'concurrent': 10, 'extensions': 60, 'dataArea': 4},
    '20/120': {'concurrent': 20, 'extensions': 120, 'dataArea': 4},
    '30/240': {'concurrent': 30, 'extensions': 240, 'dataArea': 6},
    '30/500': {'concurrent': 30, 'extensions': 500, 'dataArea': 6},
    '30/1000': {'concurrent': 30, 'extensions': 1000, 'dataArea': 8},
  };

  @override
  void initState() {
    super.initState();
    customStorageController.addListener(_updateActualCapacity);
    customStorageController.addListener(_updateNotification);
    phoneCountController.addListener(_updateNotification);
    recordDaysController.addListener(_updateNotification);
    // 設定初始通知訊息
    notificationController.text = '請完成以上所有選項設定，然後點擊「計算結果」';
  }

  @override
  void dispose() {
    customStorageController.dispose();
    phoneCountController.dispose();
    recordDaysController.dispose();
    dailyCallController.dispose();
    monthlyCallController.dispose();
    recordingCapacityController.dispose();
    recommendedStorageController.dispose();
    notificationController.dispose();
    super.dispose();
  }

  void _updateActualCapacity() {
    if (storageType != null) {
      setState(() {
        if (storageType == '32GB(標準版)') {
          actualUsableCapacity = 32.0 * 0.8;
        } else if (storageType == '自訂' && customStorageController.text.isNotEmpty) {
          double? customSize = double.tryParse(customStorageController.text);
          if (customSize != null && customSize > 0) {
            actualUsableCapacity = customSize * 0.8;
          } else {
            actualUsableCapacity = 0.0;
          }
        } else if (storageType == '自訂' && customStorageController.text.isEmpty) {
          actualUsableCapacity = 0.0;
        }
        _updateRecordingCapacity();
      });
    }
  }

  void _updateRecordingCapacity() {
    if (pbxSpec != null && actualUsableCapacity > 0) {
      int dataArea = pbxSpecs[pbxSpec]!['dataArea'];
      actualRecordingCapacity = actualUsableCapacity - 1 - dataArea;
      if (actualRecordingCapacity < 0) actualRecordingCapacity = 0;
    } else {
      actualRecordingCapacity = 0.0;
    }
  }

  void _updateDailyCallDuration() {
    setState(() {
      if (companyType == '一般企業') {
        dailyCallDuration = '1800秒/話機/天';
        dailyCallController.text = dailyCallDuration;
      } else if (companyType == '電訪企業') {
        dailyCallDuration = '18000秒/話機/天';
        dailyCallController.text = dailyCallDuration;
      } else {
        dailyCallDuration = '';
        dailyCallController.text = '';
      }
    });
  }

  void _updateNotification() {
    setState(() {
      if (!needsRecalculation) {
        needsRecalculation = true;
        notificationController.text = '務必點擊「計算結果」，重新計算!!';
      }
    });
  }

  String _formatToWan(int seconds) {
    if (seconds >= 10000) {
      if (seconds % 10000 == 0) {
        return '${(seconds / 10000).toInt()}萬秒';
      } else {
        return '${(seconds / 10000).toStringAsFixed(1)}萬秒';
      }
    }
    return '$seconds秒';
  }

  double _roundUpFirstDecimal(double value) {
    double firstDecimal = (value * 10) % 10;
    if (firstDecimal > 0) {
      return (value * 10).floor() / 10 + 0.1;
    }
    return value;
  }

  String _getEstimatedCapacityText() {
    // 如果選擇自訂但沒有輸入數字，顯示空的預估可用
    if (storageType == '自訂' && customStorageController.text.isEmpty) {
      return '(預估可用 GB)';
    }
    // 如果還沒選擇 PBX 規格或硬碟大小，顯示空的預估可用
    if (storageType == null || pbxSpec == null) {
      return '(預估可用 GB)';
    }
    // 如果有計算出實際錄音容量，顯示數值
    if (actualRecordingCapacity > 0) {
      return '(預估可用${actualRecordingCapacity.toStringAsFixed(1)}GB)';
    }
    // 其他情況顯示空的預估可用
    return '(預估可用 GB)';
  }

  void _calculateResults() {
    List<String> errors = [];

    // Validation
    if (audioFormat == null) errors.add('請選擇語音編碼格式');
    if (storageType == null) errors.add('請選擇硬碟大小');
    if (pbxSpec == null) errors.add('請選擇PBX規格');
    if (companyType == null) errors.add('請選擇公司類型');
    
    if (phoneCountController.text.isEmpty) {
      errors.add('請填寫話機數量');
    } else {
      double? phoneCount = double.tryParse(phoneCountController.text);
      if (phoneCount == null) {
        errors.add('話機數量請輸入數字！');
      } else if (phoneCount < 0) {
        errors.add('話機數量請勿輸入負數！');
      } else if (pbxSpec != null && phoneCount > pbxSpecs[pbxSpec]!['extensions']) {
        errors.add('話機數量不可超過PBX規格的分機數量上限');
      }
    }

    if (recordDaysController.text.isEmpty) {
      errors.add('請填寫錄音天數');
    } else {
      double? recordDays = double.tryParse(recordDaysController.text);
      if (recordDays == null) {
        errors.add('錄音天數請輸入數字！');
      } else if (recordDays < 0) {
        errors.add('錄音天數請勿輸入負數！');
      } else if (recordDays > 365) {
        // 錄音天數超過365天不再作為錯誤，改為後續提示
      }
    }

    if (storageType == '自訂') {
      if (customStorageController.text.isEmpty) {
        errors.add('請填寫自訂硬碟大小');
      } else {
        double? customSize = double.tryParse(customStorageController.text);
        if (customSize == null) {
          errors.add('自訂硬碟大小請輸入數字！');
        } else if (customSize < 0) {
          errors.add('自訂硬碟大小請勿輸入負數！');
        }
      }
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    // Calculate results
    double phoneCount = double.parse(phoneCountController.text);
    double recordDays = double.parse(recordDaysController.text);
    
    // Monthly call seconds
    int dailySeconds = companyType == '一般企業' ? 1800 : 18000;
    int totalSeconds = (dailySeconds * phoneCount * recordDays).toInt();
    monthlyCallSeconds = _formatToWan(totalSeconds);

    // Recording capacity
    int bytesPerSecond = audioFormat == 'G.729(8 kbps)' ? 1000 : 8000;
    double recordingGB = (totalSeconds * bytesPerSecond / 1048576 / 1024 * 1.5);
    recordingCapacity = '${_roundUpFirstDecimal(recordingGB).toStringAsFixed(1)}GB';

    // Recommended storage
    double totalUsage = 1 + pbxSpecs[pbxSpec]!['dataArea'] + _roundUpFirstDecimal(recordingGB);
    
    if (totalUsage <= 25) {
      recommendedStorage = '32GB';
    } else if (totalUsage <= 102) {
      recommendedStorage = '128GB';
    } else if (totalUsage <= 204) {
      recommendedStorage = '256GB';
    } else if (totalUsage <= 820) {
      recommendedStorage = '1TB';
    } else if (totalUsage <= 1638) {
      recommendedStorage = '2TB';
    } else {
      recommendedStorage = '外掛R6錄音備份系統，可直接延長錄音備份至2年';
    }

    setState(() {
      isCalculated = true;
      needsRecalculation = false;
      monthlyCallController.text = monthlyCallSeconds;
      recordingCapacityController.text = recordingCapacity;
      recommendedStorageController.text = recommendedStorage;
      notificationController.text = '計算成功！';
    });

    // 檢查錄音天數是否超過365天，顯示提示
    if (recordDays > 365) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提示', style: TextStyle(fontSize: 24)),
          content: Text('錄音天數超過365天，可外掛R6錄音備份系統，延長錄音備份至2年', style: TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('確定', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('錯誤', style: TextStyle(fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((error) => Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text('• $error', style: TextStyle(fontSize: 20)),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  void _showCalculationProcess() {
    // 如果需要重新計算或尚未計算，都顯示提示
    if (!isCalculated || needsRecalculation) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提示', style: TextStyle(fontSize: 24)),
          content: Text('請先點擊「計算結果」按鈕進行計算', style: TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('確定', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      );
      return;
    }

    String storageSize = storageType == '32GB(標準版)' ? '32' : customStorageController.text;
    String pbxDataArea = '${pbxSpecs[pbxSpec]!['dataArea']}GB';
    String phoneCount = phoneCountController.text;
    String recordDays = recordDaysController.text;
    String dailySecondsText = companyType == '一般企業' ? '1800' : '18000';
    String formatText = audioFormat == 'G.729(8 kbps)' ? '1000bytes(G.729)' : '8000bytes(G.711)';

    String processText = '''詳細結果:
硬碟容量
'$storageSize'*0.8=#${actualUsableCapacity}#GB

(1)
錄音保存容量可用
${actualUsableCapacity}G-1GB(系統區)-$pbxDataArea='${actualRecordingCapacity}GB'
(2)
每月通話秒數(預估)
'$phoneCount'台話機*'$recordDays'錄音天數*'$dailySecondsText'每支話機/每天平均通話秒數='$monthlyCallSeconds'
(3)
錄音占用容量
'$monthlyCallSeconds'每月通話秒數*$formatText/1048576(轉MB)/1024(轉GB)*1.5(預留)=$recordingCapacity
(4)
建議使用硬碟
1GB PBX系統區+'${pbxSpecs[pbxSpec]!['dataArea']}GB' PBX資料區+錄音佔用容量$recordingCapacity=${1 + pbxSpecs[pbxSpec]!['dataArea'] + double.parse(recordingCapacity.replaceAll('GB', ''))}GB，故建議'$recommendedStorage'
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('背景計算過程', style: TextStyle(fontSize: 24)),
        content: SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 24),
              children: _buildHighlightedText(processText),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text) {
    List<TextSpan> spans = [];
    // 同時匹配單引號和井號標記
    RegExp regExp = RegExp(r"'([^']*)'|#([^#]*)#");
    int lastEnd = 0;
    
    for (Match match in regExp.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      // group(1) 是單引號內容，group(2) 是井號內容
      String highlightedText = match.group(1) ?? match.group(2) ?? '';
      spans.add(TextSpan(
        text: highlightedText,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    
    return spans;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: 1),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child, Color? color}) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _buildRadioGroup<T>(String title, List<T> options, T? groupValue, void Function(T?) onChanged, {List<String>? labels}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        ...options.map((option) {
          String label = labels?[options.indexOf(option)] ?? option.toString();
          return RadioListTile<T>(
            title: Text(label, style: TextStyle(fontSize: 16)),
            value: option,
            groupValue: groupValue,
            onChanged: onChanged,
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          );
        }),
      ],
    );
  }

  Widget _buildHorizontalRadioGroup<T>(String title, List<T> options, T? groupValue, void Function(T?) onChanged, {List<String>? labels}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Row(
          children: options.map((option) {
            String label = labels?[options.indexOf(option)] ?? option.toString();
            return Expanded(
              child: RadioListTile<T>(
                title: Text(label, style: TextStyle(fontSize: 16)),
                value: option,
                groupValue: groupValue,
                onChanged: onChanged,
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }

  EdgeInsets _getFieldPadding(BuildContext context) {
    return _isDesktop(context) 
      ? EdgeInsets.symmetric(horizontal: 12, vertical: 12)
      : EdgeInsets.symmetric(horizontal: 6, vertical: 6);
  }

  bool _getFieldDense(BuildContext context) {
    return !_isDesktop(context);
  }

  double _getResultSpacing(BuildContext context) {
    return _isDesktop(context) ? 12.0 : 4.0;
  }

  Widget _buildUnitLabel(BuildContext context, String unit) {
    return Container(
      constraints: BoxConstraints(
        minHeight: _isDesktop(context) ? 48.0 : 36.0, // 最小高度匹配欄位
      ),
      padding: _getFieldPadding(context).copyWith(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildInputSections(BuildContext context) {
    return Column(
      children: [
        // 第1區：語音編碼格式 - 淺藍色
        _buildSectionCard(
          color: Colors.blue[50],
          child: _buildHorizontalRadioGroup<String>(
            '語音編碼格式',
            ['G.729(8 kbps)', 'G.711（64 kbps）'],
            audioFormat,
            (value) {
              setState(() => audioFormat = value);
              _updateNotification();
            },
          ),
        ),

        // 第2區：硬碟大小 + PBX規格 - 淺綠色
        _buildSectionCard(
          color: Colors.green[50],
          child: Column(
            children: [
              // 硬碟大小
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('硬碟大小'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('32GB(標準版)', style: TextStyle(fontSize: 16)),
                          value: '32GB(標準版)',
                          groupValue: storageType,
                          onChanged: (value) {
                            setState(() {
                              storageType = value;
                              _updateActualCapacity();
                            });
                            _updateNotification();
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Row(
                            children: [
                              Text('自訂', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: customStorageController,
                                        enabled: storageType == '自訂',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                        style: TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          isDense: _getFieldDense(context),
                                          contentPadding: _getFieldPadding(context),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    _buildUnitLabel(context, 'GB'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: '自訂',
                          groupValue: storageType,
                          onChanged: (value) {
                            setState(() {
                              storageType = value;
                              _updateActualCapacity();
                            });
                            _updateNotification();
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 6),
              
              // PBX規格
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('PBX規格'),
                  Text('同時通話/分機數量', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 2),
                  DropdownButtonFormField<String>(
                    value: pbxSpec,
                    items: pbxSpecs.keys.map((spec) => DropdownMenuItem(
                      value: spec,
                      child: Text(spec, style: TextStyle(fontSize: 16)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        pbxSpec = value;
                        _updateRecordingCapacity();
                      });
                      _updateNotification();
                    },
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: _getFieldDense(context),
                      contentPadding: _getFieldPadding(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 第3區：公司類型 + 話機數量 + 錄音天數 - 淺橙色
        _buildSectionCard(
          color: Colors.orange[50],
          child: Column(
            children: [
              // 公司類型
              _buildHorizontalRadioGroup<String>(
                '公司類型',
                ['一般企業', '電訪企業'],
                companyType,
                (value) {
                  setState(() {
                    companyType = value;
                    _updateDailyCallDuration();
                  });
                  _updateNotification();
                },
              ),

              SizedBox(height: 4),

              // 話機數量
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('話機數量'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneCountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: _getFieldDense(context),
                            contentPadding: _getFieldPadding(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      _buildUnitLabel(context, '支'),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 4),

              // 錄音天數
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('錄音天數'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: recordDaysController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: _getFieldDense(context),
                            contentPadding: _getFieldPadding(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      _buildUnitLabel(context, '天'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    return _buildSectionCard(
      color: Colors.purple[50],
      child: Column(
        children: [
          // 每天平均通話秒數
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('每支話機/每天平均通話秒數'),
              TextField(
                controller: dailyCallController,
                readOnly: true,
                enableInteractiveSelection: false,
                mouseCursor: SystemMouseCursors.basic,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[100],
                  filled: true,
                  isDense: _getFieldDense(context),
                  contentPadding: _getFieldPadding(context),
                ),
              ),
            ],
          ),

          SizedBox(height: _getResultSpacing(context)),

          // 每月通話秒數
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('每月通話秒數(預估)'),
              TextField(
                controller: monthlyCallController,
                readOnly: true,
                enableInteractiveSelection: false,
                mouseCursor: SystemMouseCursors.basic,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[100],
                  filled: true,
                  isDense: _getFieldDense(context),
                  contentPadding: _getFieldPadding(context),
                ),
              ),
            ],
          ),

          SizedBox(height: _getResultSpacing(context)),

          // 錄音佔用容量
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('錄音佔用容量${_getEstimatedCapacityText()}'),
              TextField(
                controller: recordingCapacityController,
                readOnly: true,
                enableInteractiveSelection: false,
                mouseCursor: SystemMouseCursors.basic,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[100],
                  filled: true,
                  isDense: _getFieldDense(context),
                  contentPadding: _getFieldPadding(context),
                ),
              ),
            ],
          ),

          SizedBox(height: _getResultSpacing(context)),

          // 建議使用硬碟容量大小
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('建議使用硬碟容量大小'),
              TextField(
                controller: recommendedStorageController,
                readOnly: true,
                enableInteractiveSelection: false,
                mouseCursor: SystemMouseCursors.basic,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[100],
                  filled: true,
                  isDense: _getFieldDense(context),
                  contentPadding: _getFieldPadding(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return _buildSectionCard(
      color: needsRecalculation ? Colors.red[50] : (isCalculated ? Colors.green[50] : Colors.blue[50]),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: needsRecalculation ? Colors.red : (isCalculated ? Colors.green : Colors.blue),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          notificationController.text,
          style: TextStyle(
            fontSize: 18,
            color: needsRecalculation ? Colors.red : (isCalculated ? Colors.green : Colors.blue),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _calculateResults,
            child: Text('計算結果', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 7),
            ),
          ),
        ),
        SizedBox(width: 7),
        Expanded(
          child: ElevatedButton(
            onPressed: _showCalculationProcess,
            child: Text('顯示背景計算過程', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildInputSections(context),
        _buildNotificationCard(),
        _buildResultsSection(context),
        SizedBox(height: 9),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // 第一行：輸入區域（左側）+ 結果區域（右側）
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左側輸入區域
            Expanded(
              flex: 2,
              child: _buildInputSections(context),
            ),
            SizedBox(width: 16),
            // 右側結果區域
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildResultsSection(context),
                  SizedBox(height: 48),
                  _buildActionButtons(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildNotificationCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = _isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('IP PBX建議錄音天數計算', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 16 : 7),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : 460,
            ),
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),
        ),
      ),
    );
  }
}