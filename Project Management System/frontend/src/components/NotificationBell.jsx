import React, { useState } from 'react';
import api from '../api/axiosInstance';
import { Bell, Check, X, Trash2 } from 'lucide-react';

// 1. Default 'notifications' to [] in props
const NotificationBell = ({ notifications = [], onRefresh }) => {
  const [isOpen, setIsOpen] = useState(false);
  
  // 2. SAFETY CHECK: Ensure it is actually an array before filtering
  const safeNotifications = Array.isArray(notifications) ? notifications : [];

  const unreadCount = safeNotifications.filter(n => !n.is_read).length;

  const handleMarkRead = async (id) => {
    try {
      await api.put(`/tasks/notifications/${id}/read`);
      onRefresh(); 
    } catch (err) {
      console.error(err);
    }
  };

  const handleClearAll = async () => {
    if (!window.confirm("Are you sure you want to clear all notifications?")) return;
    
    try {
      await api.delete('/tasks/notifications');
      onRefresh();
    } catch (err) {
      console.error("Failed to clear notifications:", err);
    }
  };

  return (
    <div style={{ position: 'relative' }}>
      <button 
        onClick={() => setIsOpen(!isOpen)}
        style={{ background: 'none', border: 'none', cursor: 'pointer', position: 'relative' }}
      >
        <Bell size={24} color="#64748b" />
        {unreadCount > 0 && (
          <span style={badgeStyle}>{unreadCount}</span>
        )}
      </button>

      {isOpen && (
        <div style={dropdownStyle}>
          {/* HEADER with Clear All Button */}
          <div style={headerStyle}>
            <span>Notifications</span>
            <div style={{ display: 'flex', gap: '5px', alignItems: 'center' }}>
              {safeNotifications.length > 0 && (
                <button 
                  onClick={handleClearAll} 
                  title="Clear All" 
                  style={{ ...iconBtnStyle, color: '#ef4444' }}
                >
                  <Trash2 size={16} />
                </button>
              )}
              <button 
                onClick={() => setIsOpen(false)} 
                title="Close" 
                style={{ ...iconBtnStyle, color: '#64748b' }}
              >
                <X size={16}/>
              </button>
            </div>
          </div>
          
          <div style={{ maxHeight: '300px', overflowY: 'auto' }}>
            {safeNotifications.length === 0 ? (
              <div style={{ padding: '20px', textAlign: 'center', color: '#94a3b8', fontSize: '13px' }}>No notifications</div>
            ) : (
              safeNotifications.map(n => (
                <div key={n.id} style={{ ...itemStyle, opacity: n.is_read ? 0.6 : 1, background: n.is_read ? '#fff' : '#f0f9ff' }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: '12px', fontWeight: '800', color: '#0f172a' }}>{n.title}</div>
                    <div style={{ fontSize: '12px', color: '#334155', margin: '4px 0' }}>{n.message}</div>
                    <div style={{ fontSize: '10px', color: '#94a3b8' }}>{new Date(n.created_at).toLocaleDateString()}</div>
                  </div>
                  {!n.is_read && (
                    <button onClick={() => handleMarkRead(n.id)} title="Mark Read" style={checkBtnStyle}>
                      <Check size={14} />
                    </button>
                  )}
                </div>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
};

const badgeStyle = {
  position: 'absolute', top: '-5px', right: '-5px', background: '#ef4444', color: '#fff',
  fontSize: '10px', fontWeight: 'bold', borderRadius: '50%', width: '16px', height: '16px',
  display: 'flex', alignItems: 'center', justifyContent: 'center'
};

const dropdownStyle = {
  position: 'absolute', right: 0, top: '40px', width: '300px', background: '#fff',
  borderRadius: '8px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)',
  zIndex: 1000
};

const headerStyle = {
  padding: '12px', borderBottom: '1px solid #e2e8f0', fontWeight: '800', 
  display: 'flex', justifyContent: 'space-between', alignItems: 'center'
};

const itemStyle = { padding: '12px', borderBottom: '1px solid #f1f5f9', display: 'flex', gap: '10px', alignItems: 'start' };
const checkBtnStyle = { border: 'none', background: '#dcfce7', color: '#166534', borderRadius: '4px', padding: '4px', cursor: 'pointer' };
const iconBtnStyle = { border: 'none', background: 'none', cursor: 'pointer', padding: '4px', display: 'flex', alignItems: 'center' };

export default NotificationBell;