import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// =============================================
// HOW TO USE:
// 1. Run: flutter run -d YOUR_DEVICE
//    and change main.dart temporarily to:
//    void main() => runApp(CalibrationApp());
// 2. Select the board (Jungle or City)
// 3. Tap the board where each square is
// 4. Use the step buttons to move between squares
// 5. Copy the output and paste into main.dart
// =============================================

void main() => runApp(const CalibrationApp());

class CalibrationApp extends StatelessWidget {
  const CalibrationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Board Calibration',
      debugShowCheckedModeBanner: false,
      home: CalibrationPage(),
    );
  }
}

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({Key? key}) : super(key: key);

  @override
  _CalibrationPageState createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  // --- BOARD SELECTION ---
  String _boardType = 'jungle'; // 'jungle' or 'city'

  // --- CURRENT STEP ---
  int _currentStep = 1;

  // --- CURRENT TOKEN POSITION (relative 0.0 to 1.0) ---
  double _tokenX = 0.5;
  double _tokenY = 0.5;

  // --- SAVED COORDINATES per board ---
  // Format: { stepNumber: Offset(x, y) }
  final Map<String, Map<int, Offset>> _saved = {
    'jungle': {},
    'city': {},
  };

  // Board images
  String get _boardImage => _boardType == 'jungle'
      ? 'images/IMG-20240301-WA0006.jpg'
      : 'images/IMG-20240305-WA0002.jpg';

  // =============================================
  // SAVE CURRENT STEP
  // =============================================
  void _saveStep() {
    setState(() {
      _saved[_boardType]![_currentStep] = Offset(
        double.parse(_tokenX.toStringAsFixed(3)),
        double.parse(_tokenY.toStringAsFixed(3)),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Step $_currentStep saved: '
          '(${_tokenX.toStringAsFixed(3)}, ${_tokenY.toStringAsFixed(3)})',
        ),
        backgroundColor: Colors.green[800],
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // =============================================
  // LOAD STEP (restore saved position if exists)
  // =============================================
  void _loadStep(int step) {
    setState(() {
      _currentStep = step.clamp(0, 34);
      if (_saved[_boardType]!.containsKey(_currentStep)) {
        _tokenX = _saved[_boardType]![_currentStep]!.dx;
        _tokenY = _saved[_boardType]![_currentStep]!.dy;
      }
    });
  }

  // =============================================
  // BUILD OUTPUT STRING
  // =============================================
  String _buildOutput() {
    final coords = _saved[_boardType]!;
    if (coords.isEmpty) return '// Tap the board and save steps to see output';

    final lines = <String>[];
    lines.add('// --- ${_boardType.toUpperCase()} COORDS ---');
    lines.add('const Map<int, Offset> ${_boardType}Coords = {');

    final sortedKeys = coords.keys.toList()..sort();
    for (final key in sortedKeys) {
      final o = coords[key]!;
      lines.add(
        '  $key: Offset(${o.dx.toStringAsFixed(3)}, '
        '${o.dy.toStringAsFixed(3)}),',
      );
    }
    lines.add('};');
    return lines.join('\n');
  }

  // =============================================
  // COPY OUTPUT TO CLIPBOARD
  // =============================================
  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _buildOutput()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Copied to clipboard!'),
        backgroundColor: Colors.green[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =============================================
  // HANDLE TAP ON BOARD
  // =============================================
  void _onBoardTap(TapDownDetails details, BoxConstraints constraints) {
    final size = constraints.biggest;
    final boardSize = size.width < size.height ? size.width : size.height;
    setState(() {
      _tokenX = (details.localPosition.dx / boardSize).clamp(0.0, 1.0);
      _tokenY = (details.localPosition.dy / boardSize).clamp(0.0, 1.0);
    });
  }

  // =============================================
  // BUILD
  // =============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF145a32),
        title: const Text('🎯 Board Calibration Tool'),
        actions: [
          // Board selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _boardType,
              dropdownColor: const Color(0xFF1e8449),
              style: const TextStyle(color: Colors.white),
              underline: Container(height: 1, color: Colors.green),
              items: const [
                DropdownMenuItem(
                  value: 'jungle',
                  child: Text('🌿 Jungle'),
                ),
                DropdownMenuItem(
                  value: 'city',
                  child: Text('🏙️ City'),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _boardType = val!;
                  _tokenX = 0.5;
                  _tokenY = 0.5;
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [

          // =============================================
          // BOARD — tap to place token
          // =============================================
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boardSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;

                return Center(
                  child: GestureDetector(
                    onTapDown: (details) =>
                        _onBoardTap(details, constraints),
                    child: SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: Stack(
                        children: [

                          // Board image
                          Image.asset(
                            _boardImage,
                            width: boardSize,
                            height: boardSize,
                            fit: BoxFit.contain,
                          ),

                          // All saved tokens (grey)
                          ..._saved[_boardType]!.entries.map((entry) {
                            final step = entry.key;
                            final pos = entry.value;
                            return Positioned(
                              left: pos.dx * boardSize - boardSize * 0.04,
                              top: pos.dy * boardSize - boardSize * 0.04,
                              child: Container(
                                width: boardSize * 0.08,
                                height: boardSize * 0.08,
                                decoration: BoxDecoration(
                                  color: step == _currentStep
                                      ? Colors.green
                                      : Colors.grey.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$step',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Current token (red = unsaved position)
                          Positioned(
                            left: _tokenX * boardSize - boardSize * 0.04,
                            top: _tokenY * boardSize - boardSize * 0.04,
                            child: Container(
                              width: boardSize * 0.08,
                              height: boardSize * 0.08,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$_currentStep',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // =============================================
          // CONTROLS
          // =============================================
          Container(
            color: const Color(0xFF2a2a2a),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [

                // Position display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Step $_currentStep  |  '
                      'X: ${_tokenX.toStringAsFixed(3)}  '
                      'Y: ${_tokenY.toStringAsFixed(3)}',
                      style: const TextStyle(
                        color: Color(0xFF2ecc71),
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // X slider
                Row(
                  children: [
                    const SizedBox(
                      width: 30,
                      child: Text('X',
                          style: TextStyle(color: Color(0xFFa9dfbf))),
                    ),
                    Expanded(
                      child: Slider(
                        value: _tokenX,
                        min: 0.0,
                        max: 1.0,
                        activeColor: const Color(0xFF2ecc71),
                        inactiveColor: Colors.grey,
                        onChanged: (val) =>
                            setState(() => _tokenX = val),
                      ),
                    ),
                    SizedBox(
                      width: 45,
                      child: Text(
                        _tokenX.toStringAsFixed(3),
                        style: const TextStyle(
                          color: Color(0xFF2ecc71),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),

                // Y slider
                Row(
                  children: [
                    const SizedBox(
                      width: 30,
                      child: Text('Y',
                          style: TextStyle(color: Color(0xFFa9dfbf))),
                    ),
                    Expanded(
                      child: Slider(
                        value: _tokenY,
                        min: 0.0,
                        max: 1.0,
                        activeColor: const Color(0xFF2ecc71),
                        inactiveColor: Colors.grey,
                        onChanged: (val) =>
                            setState(() => _tokenY = val),
                      ),
                    ),
                    SizedBox(
                      width: 45,
                      child: Text(
                        _tokenY.toStringAsFixed(3),
                        style: const TextStyle(
                          color: Color(0xFF2ecc71),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Step navigation buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Prev / Next
                      _btn('◀', () => _loadStep(_currentStep - 1)),
                      const SizedBox(width: 6),
                      _btn('Next ▶', () => _loadStep(_currentStep + 1)),
                      const SizedBox(width: 12),

                      // Step number buttons 0-34
                      ...List.generate(35, (i) {
                        final isSaved =
                            _saved[_boardType]!.containsKey(i);
                        final isActive = i == _currentStep;
                        return GestureDetector(
                          onTap: () => _loadStep(i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF1e8449)
                                  : isSaved
                                      ? const Color(0xFF145a32)
                                      : const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFF2ecc71)
                                    : isSaved
                                        ? const Color(0xFF27ae60)
                                        : const Color(0xFF555555),
                              ),
                            ),
                            child: Text(
                              '$i',
                              style: TextStyle(
                                color: isActive || isSaved
                                    ? Colors.white
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _btn('💾 Save Step', _saveStep,
                        color: const Color(0xFF1e8449)),
                    const SizedBox(width: 8),
                    _btn('📋 Copy Output', _copyOutput,
                        color: const Color(0xFF1a5276)),
                    const SizedBox(width: 8),
                    _btn('🗑️ Clear', () {
                      setState(() => _saved[_boardType]!.clear());
                    }, color: const Color(0xFF922b21)),
                  ],
                ),
              ],
            ),
          ),

          // =============================================
          // OUTPUT
          // =============================================
          Container(
            color: const Color(0xFF0a0a0a),
            padding: const EdgeInsets.all(12),
            height: 120,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Text(
                _buildOutput(),
                style: const TextStyle(
                  color: Color(0xFF2ecc71),
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper button builder
  Widget _btn(String label, VoidCallback onTap,
      {Color color = const Color(0xFF1e8449)}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(label,
          style: const TextStyle(fontSize: 13, color: Colors.white)),
    );
  }
}
