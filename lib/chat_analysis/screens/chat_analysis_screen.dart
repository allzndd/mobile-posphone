import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';

class ChatAnalysisScreen extends StatefulWidget {
  const ChatAnalysisScreen({super.key});

  @override
  State<ChatAnalysisScreen> createState() => _ChatAnalysisScreenState();
}

class _ChatAnalysisScreenState extends State<ChatAnalysisScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Sample chat messages - Structure matched with web-posphone
  // This will integrate with ChatAnalysisController
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'role': 'assistant',
      'content':
          'Halo! Saya adalah asisten AI untuk analisis bisnis POS Anda. Apa yang ingin Anda ketahui?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': _messages.length + 1,
        'role': 'user',
        'content': _messageController.text.trim(),
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': _messages.length + 1,
            'role': 'assistant',
            'content':
                'Terima kasih atas pertanyaan Anda. Saya sedang menganalisis data... (Integrasi API akan dilakukan di sini)',
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Column(
        children: [
          _buildHeader(isDesktop, themeProvider),
          Expanded(child: _buildChatArea(isDesktop, themeProvider)),
          _buildInputArea(isDesktop, themeProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
              children: [
                Text(
                  'AI Business Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Analisis & Insight Berbasis AI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            Material(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _showSuggestedQuestions(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Saran Pertanyaan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatArea(bool isDesktop, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildLoadingBubble(themeProvider);
          }
          return _buildMessageBubble(
            _messages[index],
            isDesktop,
            themeProvider,
          );
        },
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.primaryMain,
                    themeProvider.secondaryMain,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? themeProvider.primaryMain
                        : themeProvider.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
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
                  Text(
                    message['content'],
                    style: TextStyle(
                      color: isUser ? Colors.white : themeProvider.textPrimary,
                      fontSize: isDesktop ? 15 : 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color:
                          isUser ? Colors.white70 : themeProvider.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeProvider.secondaryMain,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.primaryMain,
                  themeProvider.secondaryMain,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeProvider.primaryMain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sedang berpikir...',
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
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
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
          if (!isDesktop)
            IconButton(
              icon: Icon(
                Icons.lightbulb_outline,
                color: themeProvider.primaryMain,
              ),
              onPressed: _showSuggestedQuestions,
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: themeProvider.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeProvider.borderColor),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Tanyakan tentang bisnis Anda...',
                  hintStyle: TextStyle(color: themeProvider.textTertiary),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: themeProvider.primaryMain,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: isDesktop ? 24 : 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuggestedQuestions() {
    final suggestions = [
      'Berapa total penjualan bulan ini?',
      'Produk apa yang paling laku?',
      'Bagaimana performa toko cabang?',
      'Analisis tren penjualan minggu ini',
      'Pelanggan mana yang paling sering berbelanja?',
      'Rekomendasi untuk meningkatkan penjualan',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final themeProvider = context.read<ThemeProvider>();
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
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
                        Icon(
                          Icons.lightbulb_outline,
                          color: themeProvider.primaryMain,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Saran Pertanyaan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          leading: Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: themeProvider.textSecondary,
                          ),
                          title: Text(
                            suggestion,
                            style: TextStyle(color: themeProvider.textPrimary),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _messageController.text = suggestion;
                            _sendMessage();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} jam yang lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
