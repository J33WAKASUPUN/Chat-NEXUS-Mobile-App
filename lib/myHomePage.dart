import 'package:chat_nexus_mobile_app/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

import 'package:chat_nexus_mobile_app/main.dart';
import 'package:chat_nexus_mobile_app/pages/login_page.dart';
import 'package:chat_nexus_mobile_app/auth/auth_service.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}



class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final buttons = [
      {
        'icon': Icons.summarize,
        'text': 'Summarize text',
        'color': const Color.fromARGB(255, 255, 69, 69)
      },
      {'icon': Icons.edit, 'text': 'Help me write', 'color': const Color.fromARGB(255, 255, 69, 69)},
      {'icon': Icons.bar_chart, 'text': 'Analyze data', 'color': const Color.fromARGB(255, 255, 69, 69)},
      {
        'icon': Icons.lightbulb_outline,
        'text': 'Brainstorm',
        'color': const Color.fromARGB(255, 255, 69, 69)
      },
      {'icon': Icons.code, 'text': 'Code', 'color': const Color.fromARGB(255, 255, 69, 69)},
      {'icon': Icons.schedule, 'text': 'Make a plan', 'color': const Color.fromARGB(255, 255, 69, 69)},
      {
        'icon': Icons.card_giftcard,
        'text': 'Surprise me',
        'color': const Color.fromARGB(255, 255, 69, 69)
      },
      {'icon': Icons.school, 'text': 'Get advice', 'color': const Color.fromARGB(255, 255, 69, 69)},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 5,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: buttons.map((button) {
        return Container(
          height: 16,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: MaterialButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      button['icon'] as IconData,
                      color: button['color'] as Color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      button['text'] as String,
                      style: TextStyle(
                        color: isDarkMode
                            ? const Color.fromARGB(182, 255, 255, 255)
                            : Colors.black87,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showScrollToBottom = false;
  bool _isTyping = false;
  final List<Message> _messages = [];

  static const Color primaryBlue = Color.fromARGB(255, 255, 69, 69);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _controller.addListener(_textListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 100) {
      setState(() => _showScrollToBottom = true);
    } else {
      setState(() => _showScrollToBottom = false);
    }
  }

  void _textListener() {
    setState(() => _isTyping = _controller.text.isNotEmpty);
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

Widget _buildMessage(Message message) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Column(
      crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isUser) 
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: primaryBlue.withOpacity(0.2),
                  radius: 16,
                  child: Image.asset(
                    'assets/gpt-robot.png',
                    height: 20,
                    width: 20,
                    color: primaryBlue,
                  ),
                ),
              ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? primaryBlue
                      :  Theme.of(context).colorScheme.tertiary,
                  borderRadius: message.isUser
                      ? const BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),

                        )
                      : const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.text.contains('```'))
                      _buildCodeBlock(message.text, isDarkMode)
                    else
                      MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: message.isUser
                                ? Colors.white
                                : (isDarkMode ? Colors.white : Colors.black87),
                          ),
                          code: TextStyle(
                            backgroundColor: isDarkMode 
                                ? const Color.fromARGB(255, 0, 0, 0) 
                                : Colors.grey[200],
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: isDarkMode 
                                ? const Color.fromARGB(255, 0, 0, 0) 
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (message.isUser)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  backgroundColor: primaryBlue.withOpacity(0.2),
                  radius: 16,
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: primaryBlue,
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 4.0,
            right: message.isUser ? 40.0 : 4.0,
            left: message.isUser ? 4.0 : 40.0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatDateTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.white60 : Colors.black45,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCodeBlock(String text, bool isDarkMode) {
  final codeRegex = RegExp(r'```(\w+)?\n?(.*?)```', dotAll: true);
  final match = codeRegex.firstMatch(text);
  
  if (match == null) return const SizedBox.shrink();
  
  final language = match.group(1)?.toLowerCase() ?? 'text';
  final code = match.group(2)?.trim() ?? '';

  // Define syntax highlighting colors using proper Color constructor
  final syntaxColors = isDarkMode ? {
    'keyword': const Color(0xFF569CD6),    // Blue
    'string': const Color(0xFFCE9178),     // Orange
    'comment': const Color(0xFF6A9955),    // Green
    'number': const Color(0xFFB5CEA8),     // Light Green
    'identifier': const Color(0xFF9CDCFE),  // Light Blue
    'background': const Color(0xFF1E1E1E), // Dark Gray
  } : {
    'keyword': const Color(0xFF0000FF),    // Blue
    'string': const Color(0xFFA31515),     // Red
    'comment': const Color(0xFF008000),    // Green
    'number': const Color(0xFF098658),     // Dark Green
    'identifier': const Color(0xFF001080), // Dark Blue
    'background': const Color(0xFFF8F8F8), // Light Gray
  };

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: syntaxColors['background'],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        width: 0,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Language label
        if (language != 'text')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2), // More control
            decoration: BoxDecoration(
              color: isDarkMode ? const Color.fromARGB(255, 29, 29, 29) : Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.toUpperCase(),
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 14),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                  tooltip: 'Copy code',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: primaryBlue,
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            
            child: SyntaxView(
              code: code,
              syntax: _getSyntaxFromLanguage(language),
              syntaxTheme: isDarkMode ? SyntaxTheme.ayuDark() : SyntaxTheme.ayuLight(),
              fontSize: 11,
              withZoom: false,
              withLinesCount: true,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper method to convert language string to Syntax enum with correct values
Syntax _getSyntaxFromLanguage(String language) {
  switch (language.toLowerCase()) {
    case 'dart':
    case 'javascript':
    case 'js':
      return Syntax.JAVASCRIPT; // Use JavaScript syntax for both JS and Dart
    case 'cpp':
    case 'c++':
      return Syntax.CPP;
    case 'css':
      return Syntax.C;
    case 'html':
      return Syntax.YAML;
    case 'java':
      return Syntax.JAVA;
    case 'kotlin':
      return Syntax.KOTLIN;
    case 'markdown':
    case 'php':
      return Syntax.CPP;
    case 'ruby':
      return Syntax.RUST;
    case 'swift':
      return Syntax.SWIFT;
    case 'xml':
      return Syntax.YAML;
    case 'yaml':
    case 'yml':
      return Syntax.YAML;
    default:
      return Syntax.JAVASCRIPT; // Default to JavaScript syntax
  }
}

  Future<void> callGeminiModel() async {
  if (_controller.text.isEmpty) return;

  // Verify API Key
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gemini API Key is missing')),
    );
    return;
  }

  setState(() {
    _messages.add(Message(text: _controller.text, isUser: true));
    _isLoading = true;
  });

  try {
    final model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: apiKey
    );
    
    final prompt = _controller.text.trim();
    final contentList = [Content.text(prompt)];
    
    final response = await model.generateContent(contentList);

    if (response.text == null || response.text!.isEmpty) {
      setState(() {
        _messages.add(Message(
          text: "Sorry, I couldn't generate a response.",
          isUser: false
        ));
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages.add(Message(text: response.text!, isUser: false));
        _isLoading = false;
      });
    }
    
    _controller.clear();
    _scrollToBottom();
  } catch (e) {
    setState(() => _isLoading = false);
    
    // More detailed error handling
    String errorMessage = "An error occurred";
    if (e.toString().contains("401")) {
      errorMessage = "Invalid API Key. Please check your credentials.";
    } else if (e.toString().contains("429")) {
      errorMessage = "Rate limit exceeded. Please try again later.";
    } else if (e.toString().contains("503")) {
      errorMessage = "Service unavailable. Please try again later.";
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );

    print("Gemini API Error: $e");
  }
}

  String _formatDateTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }

    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return '$dateText, $time';
  }

  @override
  void dispose() {
    _controller.removeListener(_textListener);
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: false,
        elevation: 1,
        shadowColor: Theme.of(context).appBarTheme.shadowColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/gpt-robot.png',
              height: 30,
              width: 30,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'ChatNEXUS',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                final currentMode = ref.read(themeProvider);
                ref.read(themeProvider.notifier).state =
                    currentMode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
              },
              child: Icon(
                ref.watch(themeProvider) == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                final authService = AuthService();
                await authService.signOut();
  
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context, 
                  MaterialPageRoute(builder: (context) => const Onboarding())
                );
              },
            ),
          ),
        ],
        backgroundColor: primaryBlue,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (_messages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            decoration: const BoxDecoration(
                              color: primaryBlue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: const Text(
                              "What can I help you with ?",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const ActionButtons(),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return _buildMessage(message);
                    },
                  ),
                ),
                // New chat input field design
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          onPressed: () {
                            // Add your functionality here, Todo in future versions
                          },
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: _isLoading ? null : () => callGeminiModel(),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 26,
                                      width: 26,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/send.png',
                                      height: 23,
                                      width: 23,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showScrollToBottom)
              Positioned(
                right: 16,
                bottom: 100,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _scrollToBottom,
                  backgroundColor: primaryBlue,
                  child: const Icon(Icons.arrow_downward, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}