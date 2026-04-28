import React, { useState } from 'react';
import api from '../api/axiosInstance';
import { Save, AlertCircle, ArrowLeft, Calendar, BarChart2, UserPlus, Trash2, Users } from 'lucide-react';

const TaskCreateOverlay = ({ team, users = [], onClose, onRefresh }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    state: 'TODO',
    priority: 'LOW',
    deadline: ''
  });

  const [assignedUsers, setAssignedUsers] = useState([]);
  const [selectedUserToAdd, setSelectedUserToAdd] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  // --- Assignment Logic ---
  const addMemberLocally = (e) => {
    e.preventDefault();
    if (!selectedUserToAdd) return;
    
    const userObj = users.find(u => String(u.user_id) === String(selectedUserToAdd));
    if (userObj && !assignedUsers.find(m => m.user_id === userObj.user_id)) {
      setAssignedUsers([...assignedUsers, userObj]);
    }
    setSelectedUserToAdd('');
  };

  const removeMemberLocally = (userId) => {
    setAssignedUsers(assignedUsers.filter(m => m.user_id !== userId));
  };

  const availableUsers = users.filter(u => !assignedUsers.find(m => m.user_id === u.user_id));

  // --- Submission Logic ---
  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setError('');

    const payload = {
      ...formData,
      team_id: team.id,
      deadline: formData.deadline ? new Date(formData.deadline).toISOString() : null,
      assignee_ids: assignedUsers.map(u => u.user_id)
    };

    try {
      await api.post(`/tasks/${team.id}/tasks`, payload);
      onRefresh(); 
      onClose();   
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to create task.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
      <button 
        onClick={onClose} 
        style={{ background: 'none', border: 'none', color: '#64748b', display: 'flex', alignItems: 'center', gap: '5px', cursor: 'pointer', fontWeight: '700', fontSize: '14px' }}
      >
        <ArrowLeft size={16} /> Back to List
      </button>

      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {error && (
          <div style={formStyles.errorMsg}>
            <AlertCircle size={16} /> {error}
          </div>
        )}

        <div>
          <label style={formStyles.label}>Task Title</label>
          <textarea
            required
            type="text"
            rows="1"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            placeholder="e.g. Core Database Migration"
            style={formStyles.input}
          />
        </div>

        <div>
          <label style={formStyles.label}>Description</label>
          <textarea
            rows="3"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Details about the task..."
            style={{ ...formStyles.input, resize: 'none' }}
          />
        </div>

        {/* --- ASSIGNEES SECTION --- */}
        <div>
          <label style={formStyles.label}>
            <Users size={12} style={{ marginRight: '4px' }} /> Assign Team Members
          </label>
          
          {/* List of currently assigned users */}
          <div style={formStyles.memberList}>
            {assignedUsers.length === 0 ? (
              <p style={{ textAlign: 'center', color: '#94a3b8', fontSize: '13px', margin: 0 }}>No users assigned.</p>
            ) : assignedUsers.map(member => (
              <div key={member.user_id} style={formStyles.memberItem}>
                <span style={{ fontSize: '13px', fontWeight: '500', flex: 1 }}>{member.username}</span>
                <button type="button" onClick={() => removeMemberLocally(member.user_id)} style={formStyles.deleteBtnFrame}>
                  <Trash2 size={13} />
                </button>
              </div>
            ))}
          </div>

          {/* Add Member Controls */}
          <div style={formStyles.addSection}>
            <div style={{ flex: 1 }}> {/* Flex 1 makes this box take all available width */}
              <select 
                style={{ ...formStyles.input, marginTop: 0, padding: '8px' }} 
                value={selectedUserToAdd} 
                onChange={e => setSelectedUserToAdd(e.target.value)}
              >
                <option value="">Select member...</option>
                {availableUsers.map(u => (
                  <option key={u.user_id} value={u.user_id}>{u.username}</option>
                ))}
              </select>
            </div>
            
            <button 
              type="button"
              onClick={addMemberLocally} 
              style={formStyles.addBtn}
            >
              <UserPlus size={14} /> Add
            </button>
          </div>
        </div>
        {/* ------------------------- */}

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
          <div>
            <label style={formStyles.label}>
              <BarChart2 size={12} style={{ marginRight: '4px' }} /> Priority
            </label>
            <select
              value={formData.priority}
              onChange={(e) => setFormData({ ...formData, priority: e.target.value })}
              style={formStyles.input}
            >
              <option value="LOW">Low</option>
              <option value="MEDIUM">Medium</option>
              <option value="HIGH">High</option>
            </select>
          </div>

          <div>
            <label style={formStyles.label}>
              <Calendar size={12} style={{ marginRight: '4px' }} /> Deadline
            </label>
            <input
              type="datetime-local"
              value={formData.deadline}
              onChange={(e) => setFormData({ ...formData, deadline: e.target.value })}
              style={formStyles.input}
            />
          </div>
        </div>

        <button 
          type="submit" 
          disabled={submitting} 
          style={formStyles.submitBtn}
        >
          {submitting ? 'Processing...' : <><Save size={18} /> Create Task</>}
        </button>
      </form>
    </div>
  );
};

const formStyles = {
  label: { display: 'flex', alignItems: 'center', fontSize: '11px', fontWeight: '900', textTransform: 'uppercase', marginBottom: '8px', color: '#64748b' },
  input: { width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid #cbd5e1', fontSize: '14px', outline: 'none', boxSizing: 'border-box', background: '#fff' },
  submitBtn: { width: '100%', padding: '14px', background: '#0f172a', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: '800', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', marginTop: '10px' },
  errorMsg: { padding: '12px', background: '#fef2f2', color: '#b91c1c', borderRadius: '8px', fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px' },
  
  memberList: { display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '10px', background: '#f8fafc', padding: '10px', borderRadius: '8px', border: '1px solid #e2e8f0' },
  memberItem: { display: 'flex', alignItems: 'center', background: '#fff', padding: '6px 10px', borderRadius: '6px', border: '1px solid #e2e8f0', boxShadow: '0 1px 2px rgba(0,0,0,0.05)' },
  
  // Flex container to hold the wide Select and narrow Button
  addSection: { display: 'flex', gap: '8px', alignItems: 'center' },
  
  deleteBtnFrame: { background: 'none', border: 'none', color: '#ef4444', cursor: 'pointer', padding: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: 0.8 },
  
  // Compact, non-flexing button
  addBtn: { 
    flex: '0 0 auto',
    padding: '8px 12px', 
    background: '#10b981', 
    color: '#fff', 
    border: '1px solid #059669', 
    borderRadius: '8px', 
    cursor: 'pointer', 
    display: 'flex', 
    alignItems: 'center', 
    gap: '4px', 
    fontSize: '12px', 
    fontWeight: '600',
    whiteSpace: 'nowrap'
  }
};

export default TaskCreateOverlay;