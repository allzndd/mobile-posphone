import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../layouts/screens/main_layout.dart';
import '../services/chat_service.dart';
import '../models/chat_response.dart';

class ChatAnalysisScreen extends StatefulWidget {
  const ChatAnalysisScreen({super.key});

  @override
  State<ChatAnalysisScreen> createState() => _ChatAnalysisScreenState();
}

class _ChatAnalysisScreenState extends State<ChatAnalysisScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late ChatService _chatService;

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'role': 'assistant',
      'content':
          'Halo! Saya adalah asisten AI bisnis Anda. Bagaimana saya bisa membantu menganalisis data POS Anda hari ini?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();

    setState(() {
      _messages.add({
        'id': _messages.length + 1,
        'role': 'user',
        'content': userMessage,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Call API
    final response = await _chatService.sendMessage(userMessage);

    if (mounted) {
      setState(() {
        if (response.ok && response.answer != null) {
          _messages.add({
            'id': _messages.length + 1,
            'role': 'assistant',
            'content': response.answer,
            'timestamp': DateTime.now(),
            'intent': response.intent,
            'data': response.data,
          });
        } else {
          _messages.add({
            'id': _messages.length + 1,
            'role': 'assistant',
            'content':
                response.error ??
                'Terjadi kesalahan saat memproses pertanyaan.',
            'timestamp': DateTime.now(),
            'isError': true,
          });
        }
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _messages.clear();
      _messages.add({
        'id': 1,
        'role': 'assistant',
        'content':
            'Hello! I\'m your AI business assistant. How can I help you analyze your POS data today?',
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Navigate ke dashboard (index 0)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) =>
                      const MainLayout(title: 'Dashboard', selectedIndex: 0),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: Column(
          children: [
            _buildModernHeader(isDesktop, themeProvider),
            Expanded(child: _buildChatArea(isDesktop, themeProvider)),
            _buildInputArea(isDesktop, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDesktop, ThemeProvider themeProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.primaryMain,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : (isSmallScreen ? 16 : 20)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 12 : 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: isDesktop ? 28 : 24,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'AI Business Assistant',
                          style: TextStyle(
                            fontSize:
                                isDesktop ? 24 : (isSmallScreen ? 16 : 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF25D366),
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isSmallScreen) ...[
                              const SizedBox(width: 4),
                              const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isSmallScreen) ...[
                    SizedBox(height: isDesktop ? 4 : 2),
                    Text(
                      'Powered by AI',
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 11,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(bool isDesktop, ThemeProvider themeProvider) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: 8,
        ),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _messages.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _messages.length && _isLoading) {
              return _buildLoadingBubble(themeProvider, isDesktop);
            }
            return _buildMessageBubble(
              _messages[index],
              isDesktop,
              themeProvider,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    bool isDesktop,
    ThemeProvider themeProvider,
  ) {
    final isUser = message['role'] == 'user';
    final timestamp = message['timestamp'] as DateTime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: isDesktop ? 40 : 36,
              height: isDesktop ? 40 : 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.primaryMain,
                    themeProvider.primaryMain.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(isDesktop ? 20 : 18),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.primaryMain.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: isDesktop ? 22 : 20,
              ),
            ),
            SizedBox(width: isDesktop ? 12 : 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 16 : 12),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? themeProvider.primaryMain
                        : themeProvider.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isDesktop ? 16 : 12),
                  topRight: Radius.circular(isDesktop ? 16 : 12),
                  bottomLeft: Radius.circular(
                    isUser ? (isDesktop ? 16 : 12) : 4,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 4 : (isDesktop ? 16 : 12),
                  ),
                ),
                border:
                    isUser
                        ? null
                        : Border.all(
                          color: themeProvider.borderColor.withOpacity(0.3),
                        ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error styling untuk pesan error
                  if (message['isError'] == true) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message['content'],
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: isDesktop ? 14 : 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      message['content'],
                      style: TextStyle(
                        color:
                            isUser ? Colors.white : themeProvider.textPrimary,
                        fontSize: isDesktop ? 15 : 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color:
                          isUser
                              ? Colors.white.withOpacity(0.7)
                              : themeProvider.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) SizedBox(width: isDesktop ? 12 : 8),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(ThemeProvider themeProvider, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: isDesktop ? 40 : 36,
            height: isDesktop ? 40 : 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.primaryMain,
                  themeProvider.primaryMain.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 20 : 18),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.primaryMain.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: isDesktop ? 22 : 20,
            ),
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isDesktop ? 16 : 12),
                topRight: Radius.circular(isDesktop ? 16 : 12),
                bottomLeft: const Radius.circular(4),
                bottomRight: Radius.circular(isDesktop ? 16 : 12),
              ),
              border: Border.all(
                color: themeProvider.borderColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeProvider.primaryMain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thinking...',
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDesktop, ThemeProvider themeProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : (isSmallScreen ? 12 : 16),
        vertical: isDesktop ? 20 : (isSmallScreen ? 12 : 16),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : (isSmallScreen ? 12 : 16),
        vertical: isDesktop ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.tips_and_updates_outlined,
              color: themeProvider.primaryMain,
              size: isDesktop ? 24 : 20,
            ),
            onPressed: _showSuggestedQuestions,
            padding: EdgeInsets.all(isDesktop ? 8 : 4),
            constraints: const BoxConstraints(),
            tooltip: 'Suggestions',
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontSize: isDesktop ? 15 : 14,
              ),
              decoration: InputDecoration(
                hintText:
                    isSmallScreen
                        ? 'Tanya...'
                        : 'Tanyakan tentang bisnis Anda...',
                hintStyle: TextStyle(
                  color: themeProvider.textTertiary,
                  fontSize: isDesktop ? 15 : 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Material(
            color: themeProvider.primaryMain,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 9),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: isDesktop ? 22 : 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuggestedQuestions() {
    final themeProvider = context.read<ThemeProvider>();
    final suggestions = [
      'Berapa total penjualan bulan ini?',
      'Produk apa yang paling banyak terjual?',
      'Bagaimana performa toko cabang?',
      'Analisis tren penjualan minggu ini',
      'Pelanggan mana yang paling sering belanja?',
      'Rekomendasi untuk meningkatkan penjualan',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeProvider.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeProvider.primaryMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tips_and_updates,
                        color: themeProvider.primaryMain,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Suggested Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _messageController.text = suggestion;
                          _sendMessage();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 20,
                                color: themeProvider.primaryMain,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: TextStyle(
                                    color: themeProvider.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: themeProvider.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
