import 'package:flutter/material.dart';
import '../models/server_model.dart';
import '../models/channel_model.dart';
import '../services/api_service.dart';

class ServerProvider extends ChangeNotifier {
  List<ServerModel> _joinedServers = [];
  List<ServerModel> _discoveryServers = [];
  ServerModel? _currentServer;
  List<ChannelModel> _channels = [];
  ChannelModel? _currentChannel;
  List<ServerMemberModel> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServerModel> get joinedServers => _joinedServers;
  List<ServerModel> get discoveryServers => _discoveryServers;
  ServerModel? get currentServer => _currentServer;
  List<ChannelModel> get channels => _channels;
  ChannelModel? get currentChannel => _currentChannel;
  List<ServerMemberModel> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ChannelModel> get textChannels => _channels.where((c) => c.isText).toList();
  List<ChannelModel> get voiceChannels => _channels.where((c) => c.isVoice).toList();

  Future<void> fetchJoinedServers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().get('/servers');
      if (res != null && res['servers'] != null) {
        _joinedServers = (res['servers'] as List)
            .map((s) => ServerModel.fromJson(s as Map<String, dynamic>))
            .toList();

        if (_joinedServers.isNotEmpty) {
          if (_currentServer == null || !_joinedServers.any((s) => s.id == _currentServer!.id)) {
            await selectServer(_joinedServers.first);
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectServer(ServerModel server) async {
    _currentServer = server;
    notifyListeners();
    await fetchChannels(server.id);
    await fetchMembers(server.id);
  }

  Future<void> fetchChannels(String serverId) async {
    try {
      final res = await ApiService().get('/servers/$serverId/channels');
      if (res != null && res['channels'] != null) {
        _channels = (res['channels'] as List)
            .map((c) => ChannelModel.fromJson(c as Map<String, dynamic>))
            .toList();

        if (_channels.isNotEmpty) {
          // Select lounge or first text channel
          final lounge = _channels.firstWhere(
            (c) => c.name == 'lounge',
            orElse: () => _channels.first,
          );
          _currentChannel = lounge;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching channels: $e');
    }
  }

  void selectChannel(ChannelModel channel) {
    _currentChannel = channel;
    notifyListeners();
  }

  Future<void> fetchMembers(String serverId) async {
    try {
      final res = await ApiService().get('/servers/$serverId/members');
      if (res != null && res['members'] != null) {
        _members = (res['members'] as List)
            .map((m) => ServerMemberModel.fromJson(m as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching members: $e');
    }
  }

  Future<void> fetchDiscoveryServers({String? category, String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String query = '';
      final params = <String>[];
      if (category != null && category != 'Featured' && category != 'All') {
        params.add('category=${Uri.encodeComponent(category)}');
      }
      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }
      if (params.isNotEmpty) {
        query = '?${params.join('&')}';
      }

      final res = await ApiService().get('/servers/discover$query');
      if (res != null && res['servers'] != null) {
        _discoveryServers = (res['servers'] as List)
            .map((s) => ServerModel.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error discovering servers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createServer({
    required String name,
    String? description,
    String? category,
    bool isPublic = true,
    String iconColor = '#9D4EDD',
  }) async {
    try {
      final res = await ApiService().post('/servers', {
        'name': name,
        'description': description,
        'category': category ?? 'Gaming',
        'is_public': isPublic,
        'icon_color': iconColor,
      });

      if (res != null && res['server'] != null) {
        final newServer = ServerModel.fromJson(res['server']);
        _joinedServers.add(newServer);
        await selectServer(newServer);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinServer(String serverId) async {
    try {
      await ApiService().post('/servers/$serverId/join');
      await fetchJoinedServers();
      return true;
    } catch (e) {
      debugPrint('Error joining server: $e');
      return false;
    }
  }
}
