import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/mock_data_service.dart';
import '../models/appointment.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }
  
  void _addWelcomeMessage() {
    final userName = AuthService.userName ?? '用戶';
    setState(() {
      _messages.add(
        ChatMessage(
          text: '您好，$userName！歡迎使用美業管理系統。\n我是您的 AI 美業助理，可以幫您處理預約、客戶資料和查詢報表等事務。\n有什麼我可以幫您的嗎？',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isLoading = true;
    });
    
    // 確保滾動到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    
    // 模擬 AI 處理時間
    Future.delayed(const Duration(milliseconds: 800), () {
      _handleResponse(userMessage);
    });
  }
  
  void _handleResponse(String userMessage) {
    String response = '';
    List<String> quickReplies = [];
    
    // 根據用戶訊息生成回應
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('預約') || lowerMessage.contains('今天') || lowerMessage.contains('行程')) {
      _handleAppointmentQuery();
      return;
    } else if (lowerMessage.contains('電話') || lowerMessage.contains('號碼')) {
      _handleCustomerInfoQuery(lowerMessage);
      return;
    } else if (lowerMessage.contains('謝謝') || lowerMessage.contains('感謝')) {
      response = '不客氣！還有其他我能幫您的嗎？';
    } else {
      response = '我還在學習中，目前可以幫您查詢預約、客戶資料和營收報表。請問您需要什麼協助呢？';
      quickReplies = ['查詢今日預約', '查詢客戶資料', '查看營收報表'];
    }
    
    setState(() {
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
          quickReplies: quickReplies,
        ),
      );
      _isLoading = false;
    });
    
    // 確保滾動到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  
  void _handleAppointmentQuery() async {
    try {
      final appointments = await MockDataService.getMockAppointments();
      final today = DateTime.now();
      final todayAppointments = appointments.where((appointment) => 
        appointment.startTime.year == today.year && 
        appointment.startTime.month == today.month && 
        appointment.startTime.day == today.day
      ).toList();
      
      if (todayAppointments.isEmpty) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: '今天沒有預約行程。',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
      } else {
        final dateFormatter = DateFormat('yyyy年MM月dd日');
        final timeFormatter = DateFormat('HH:mm');
        
        String response = '今天（${dateFormatter.format(today)}）您有以下預約：\n\n';
        for (var i = 0; i < todayAppointments.length; i++) {
          final appointment = todayAppointments[i];
          response += '${i + 1}. ${timeFormatter.format(appointment.startTime)} - ${appointment.customerName} - ${appointment.serviceName}\n';
        }
        
        setState(() {
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
              quickReplies: ['新增預約', '查看明天預約'],
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: '對不起，獲取預約信息時出現了問題。',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }
    
    // 確保滾動到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  
  void _handleCustomerInfoQuery(String message) async {
    try {
      final customers = await MockDataService.getMockCustomers();
      String customerName = '';
      
      // 嘗試從訊息中提取客戶名稱
      for (var customer in customers) {
        if (message.contains(customer.name)) {
          customerName = customer.name;
          break;
        }
      }
      
      // 如果沒有找到特定客戶，假設是找林美美
      if (customerName.isEmpty) {
        customerName = '林美美';
      }
      
      final customer = customers.firstWhere(
        (c) => c.name == customerName,
        orElse: () => customers.first,
      );
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: '$customerName的聯絡電話是：${customer.phone}\n要幫您撥打電話或發送簡訊嗎？\n或者您需要查看她的客戶資料嗎？',
            isUser: false,
            timestamp: DateTime.now(),
            quickReplies: ['撥打電話', '發送簡訊', '查看客戶資料'],
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: '對不起，獲取客戶信息時出現了問題。',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }
    
    // 確保滾動到最新消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  
  void _handleQuickReply(String reply) {
    _messageController.text = reply;
    _sendMessage();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 美業助理'),
        backgroundColor: Colors.grey[100],
        elevation: 1,
      ),
      body: Column(
        children: [
          // 聊天訊息列表
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(_messages[index]);
                },
              ),
            ),
          ),
          
          // 快捷功能按鈕
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            child: Row(
              children: [
                _buildQuickActionButton('新增預約'),
                const SizedBox(width: 10),
                _buildQuickActionButton('查詢客戶資料'),
                const SizedBox(width: 10),
                _buildQuickActionButton('查看營收報表'),
                const SizedBox(width: 10),
                _buildQuickActionButton('設定提醒'),
              ],
            ),
          ),
          
          // 輸入區域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                // 文字輸入框
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '輸入訊息...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 發送按鈕
                InkWell(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6C5CE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Column(
      crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 頭像
              if (!message.isUser) ...[
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF6C5CE7),
                  child: Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              
              // 消息氣泡
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser ? const Color(0xFFD0EBFF) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: message.isUser ? const Color(0xFF1C7ED6) : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              
              if (message.isUser) ...[
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[400],
                  child: const Text(
                    '我',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // 快捷回覆按鈕
        if (!message.isUser && message.quickReplies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 50, top: 5, bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.quickReplies.map((reply) {
                return InkWell(
                  onTap: () => _handleQuickReply(reply),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6C5CE7)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      reply,
                      style: const TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionButton(String text) {
    return InkWell(
      onTap: () => _handleQuickReply(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> quickReplies;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies = const [],
  });
} 