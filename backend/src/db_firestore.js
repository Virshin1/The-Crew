import { getFirestore } from './firebase.js';

/**
 * High-performance Firestore Database Adapter for The Crew
 * Mirrors all data structures and relational queries of SQLite
 */
class FirestoreAdapter {
  get db() {
    const firestore = getFirestore();
    if (!firestore) {
      throw new Error('Firestore is not initialized. Please ensure serviceAccountKey.json is provided.');
    }
    return firestore;
  }

  // ===================== USERS =====================

  async getUserById(id) {
    const doc = await this.db.collection('users').doc(id).get();
    return doc.exists ? { id: doc.id, ...doc.data() } : null;
  }

  async getUserByUsernameOrEmail(identifier) {
    const lower = identifier.toLowerCase();
    
    // Query by username
    let snap = await this.db.collection('users')
      .where('username_lower', '==', lower)
      .limit(1)
      .get();
    
    if (snap.empty) {
      // Query by email
      snap = await this.db.collection('users')
        .where('email_lower', '==', lower)
        .limit(1)
        .get();
    }

    if (snap.empty) return null;
    const doc = snap.docs[0];
    return { id: doc.id, ...doc.data() };
  }

  async createUser(userData) {
    const data = {
      ...userData,
      username_lower: userData.username.toLowerCase(),
      email_lower: userData.email.toLowerCase(),
      created_at: userData.created_at || new Date().toISOString(),
    };
    await this.db.collection('users').doc(userData.id).set(data);
    return { id: userData.id, ...data };
  }

  async updateUser(id, updates) {
    const filtered = {};
    for (const [k, v] of Object.entries(updates)) {
      if (v !== undefined) filtered[k] = v;
    }
    await this.db.collection('users').doc(id).update(filtered);
    return this.getUserById(id);
  }

  // ===================== SERVERS =====================

  async getServers() {
    const snap = await this.db.collection('servers').orderBy('created_at', 'asc').get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async getServerById(id) {
    const doc = await this.db.collection('servers').doc(id).get();
    return doc.exists ? { id: doc.id, ...doc.data() } : null;
  }

  async getJoinedServers(userId) {
    const memberSnap = await this.db.collection('server_members')
      .where('user_id', '==', userId)
      .get();

    if (memberSnap.empty) return [];

    const serverIds = memberSnap.docs.map(d => d.data().server_id);
    const servers = [];

    // Firestore allows 'in' queries up to 30 elements
    for (let i = 0; i < serverIds.length; i += 30) {
      const chunk = serverIds.slice(i, i + 30);
      const serverSnap = await this.db.collection('servers')
        .where('__name__', 'in', chunk)
        .get();
      servers.push(...serverSnap.docs.map(d => ({ id: d.id, ...d.data() })));
    }

    return servers;
  }

  async createServer(serverData) {
    const data = {
      ...serverData,
      created_at: serverData.created_at || new Date().toISOString(),
    };
    await this.db.collection('servers').doc(serverData.id).set(data);
    return { id: serverData.id, ...data };
  }

  // ===================== SERVER MEMBERS =====================

  async getServerMembers(serverId) {
    const snap = await this.db.collection('server_members')
      .where('server_id', '==', serverId)
      .get();

    const members = [];
    for (const doc of snap.docs) {
      const memberData = doc.data();
      const user = await this.getUserById(memberData.user_id);
      members.push({
        id: doc.id,
        server_id: memberData.server_id,
        user_id: memberData.user_id,
        role: memberData.role || 'MEMBER',
        activity: memberData.activity,
        joined_at: memberData.joined_at,
        username: user?.username || 'unknown',
        display_name: user?.display_name || 'Member',
        avatar_url: user?.avatar_url || null,
        status: user?.status || 'offline',
        custom_status: user?.custom_status || null,
      });
    }

    return members;
  }

  async addServerMember(id, serverId, userId, role = 'MEMBER', activity = 'Joined the crew!') {
    const data = {
      server_id: serverId,
      user_id: userId,
      role,
      activity,
      joined_at: new Date().toISOString(),
    };
    await this.db.collection('server_members').doc(id).set(data);
    return { id, ...data };
  }

  // ===================== CHANNELS =====================

  async getChannelsByServerId(serverId) {
    const snap = await this.db.collection('channels')
      .where('server_id', '==', serverId)
      .orderBy('position', 'asc')
      .get();

    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async getChannelById(id) {
    const doc = await this.db.collection('channels').doc(id).get();
    return doc.exists ? { id: doc.id, ...doc.data() } : null;
  }

  async createChannel(channelData) {
    const data = {
      ...channelData,
      created_at: channelData.created_at || new Date().toISOString(),
    };
    await this.db.collection('channels').doc(channelData.id).set(data);
    return { id: channelData.id, ...data };
  }

  // ===================== MESSAGES =====================

  async getMessagesByChannelId(channelId, limit = 50) {
    const snap = await this.db.collection('messages')
      .where('channel_id', '==', channelId)
      .orderBy('created_at', 'asc')
      .limit(limit)
      .get();

    const messages = [];
    for (const doc of snap.docs) {
      const msg = { id: doc.id, ...doc.data() };
      const user = await this.getUserById(msg.sender_id);
      const reactions = await this.getMessageReactions(msg.id);

      messages.push({
        ...msg,
        sender_name: user?.display_name || user?.username || 'Unknown',
        sender_avatar: user?.avatar_url || null,
        sender_status: user?.status || 'offline',
        reactions,
      });
    }

    return messages;
  }

  async createMessage(msgData) {
    const data = {
      ...msgData,
      created_at: msgData.created_at || new Date().toISOString(),
    };
    await this.db.collection('messages').doc(msgData.id).set(data);
    const user = await this.getUserById(msgData.sender_id);

    return {
      id: msgData.id,
      ...data,
      sender_name: user?.display_name || user?.username || 'Unknown',
      sender_avatar: user?.avatar_url || null,
      sender_status: user?.status || 'online',
      reactions: [],
    };
  }

  async getMessageReactions(messageId) {
    const snap = await this.db.collection('reactions')
      .where('message_id', '==', messageId)
      .get();

    // Group by emoji
    const grouped = {};
    for (const doc of snap.docs) {
      const r = doc.data();
      if (!grouped[r.emoji]) {
        grouped[r.emoji] = { emoji: r.emoji, count: 0, users: [] };
      }
      grouped[r.emoji].count += 1;
      grouped[r.emoji].users.push(r.user_id);
    }

    return Object.values(grouped);
  }

  async toggleReaction(messageId, userId, emoji) {
    const snap = await this.db.collection('reactions')
      .where('message_id', '==', messageId)
      .where('user_id', '==', userId)
      .where('emoji', '==', emoji)
      .limit(1)
      .get();

    if (!snap.empty) {
      // Remove reaction
      await snap.docs[0].ref.delete();
    } else {
      // Add reaction
      const id = 'r_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
      await this.db.collection('reactions').doc(id).set({
        message_id: messageId,
        user_id: userId,
        emoji,
        created_at: new Date().toISOString(),
      });
    }

    return this.getMessageReactions(messageId);
  }

  // ===================== DIRECT MESSAGES =====================

  async getDmConversations(userId) {
    // Fetch all DMs involving user
    const [sentSnap, recvSnap] = await Promise.all([
      this.db.collection('direct_messages').where('sender_id', '==', userId).get(),
      this.db.collection('direct_messages').where('receiver_id', '==', userId).get(),
    ]);

    const partnerIds = new Set();
    const allDms = [...sentSnap.docs, ...recvSnap.docs].map(d => ({ id: d.id, ...d.data() }));

    for (const dm of allDms) {
      partnerIds.add(dm.sender_id === userId ? dm.receiver_id : dm.sender_id);
    }

    const conversations = [];
    for (const partnerId of partnerIds) {
      const partner = await this.getUserById(partnerId);
      if (!partner) continue;

      const threadDms = allDms
        .filter(dm => (dm.sender_id === partnerId && dm.receiver_id === userId) ||
                      (dm.sender_id === userId && dm.receiver_id === partnerId))
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

      const lastDm = threadDms[0];
      const unreadCount = threadDms.filter(dm => dm.receiver_id === userId && !dm.is_read).length;

      conversations.push({
        partner_id: partner.id,
        display_name: partner.display_name,
        username: partner.username,
        avatar_url: partner.avatar_url,
        status: partner.status,
        custom_status: partner.custom_status,
        last_message: lastDm?.content || '',
        last_message_time: lastDm?.created_at || '',
        unread_count: unreadCount,
      });
    }

    return conversations;
  }

  async getDmMessages(userId1, userId2) {
    const [sentSnap, recvSnap] = await Promise.all([
      this.db.collection('direct_messages')
        .where('sender_id', '==', userId1)
        .where('receiver_id', '==', userId2)
        .get(),
      this.db.collection('direct_messages')
        .where('sender_id', '==', userId2)
        .where('receiver_id', '==', userId1)
        .get(),
    ]);

    const all = [...sentSnap.docs, ...recvSnap.docs]
      .map(d => ({ id: d.id, ...d.data() }))
      .sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

    return all;
  }

  async createDmMessage(dmData) {
    const data = {
      ...dmData,
      is_read: false,
      created_at: dmData.created_at || new Date().toISOString(),
    };
    await this.db.collection('direct_messages').doc(dmData.id).set(data);
    return { id: dmData.id, ...data };
  }

  // ===================== NOTIFICATIONS =====================

  async getNotifications(userId, type = null) {
    let query = this.db.collection('notifications')
      .where('user_id', '==', userId);

    if (type && type.toLowerCase() !== 'all') {
      query = query.where('type', '==', type.toLowerCase());
    }

    const snap = await query.orderBy('created_at', 'desc').get();
    const notifs = [];

    for (const doc of snap.docs) {
      const data = { id: doc.id, ...doc.data() };
      let actor = null;
      if (data.actor_id) {
        actor = await this.getUserById(data.actor_id);
      }
      notifs.push({
        ...data,
        actor_username: actor?.username || null,
        actor_display_name: actor?.display_name || null,
        actor_avatar: actor?.avatar_url || null,
      });
    }

    return notifs;
  }

  async markAllNotificationsRead(userId) {
    const snap = await this.db.collection('notifications')
      .where('user_id', '==', userId)
      .where('is_read', '==', false)
      .get();

    const batch = this.db.batch();
    snap.docs.forEach(doc => {
      batch.update(doc.ref, { is_read: true });
    });
    await batch.commit();
  }

  async markNotificationRead(id, userId) {
    const doc = await this.db.collection('notifications').doc(id).get();
    if (doc.exists && doc.data().user_id === userId) {
      await doc.ref.update({ is_read: true });
    }
  }

  // ===================== VOICE =====================

  async getVoiceParticipants(channelId) {
    const snap = await this.db.collection('voice_participants')
      .where('channel_id', '==', channelId)
      .get();

    const participants = [];
    for (const doc of snap.docs) {
      const p = doc.data();
      const user = await this.getUserById(p.user_id);
      participants.push({
        channel_id: p.channel_id,
        user_id: p.user_id,
        is_speaking: p.is_speaking || 0,
        is_muted: p.is_muted || 0,
        is_streaming: p.is_streaming || 0,
        status_text: p.status_text || 'Listening',
        joined_at: p.joined_at,
        username: user?.username || 'unknown',
        display_name: user?.display_name || 'Crew Member',
        avatar_url: user?.avatar_url || null,
      });
    }

    return participants;
  }

  async joinVoice(channelId, userId) {
    const key = `${channelId}_${userId}`;
    const data = {
      channel_id: channelId,
      user_id: userId,
      is_speaking: 0,
      is_muted: 0,
      is_streaming: 0,
      status_text: 'Listening',
      joined_at: new Date().toISOString(),
    };
    await this.db.collection('voice_participants').doc(key).set(data);
    return data;
  }

  async leaveVoice(channelId, userId) {
    const key = `${channelId}_${userId}`;
    await this.db.collection('voice_participants').doc(key).delete();
  }
}

const firestoreAdapter = new FirestoreAdapter();
export default firestoreAdapter;
