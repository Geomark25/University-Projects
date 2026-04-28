import React, { useState, useEffect } from 'react';
import { Trash2, UserPlus, Users } from 'lucide-react';
import api from '../api/axiosInstance';
import { styles } from './adminStyles';

const TeamCreateOverlay = ({ onClose, onRefresh, users }) => {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [selectedMembers, setSelectedMembers] = useState([]);
  const [leaderId, setLeaderId] = useState('');
  const [selectedUserToAdd, setSelectedUserToAdd] = useState('');
  const [loading, setLoading] = useState(false);

  // 1. Local Membership Logic (Before Database Creation)
  const addMemberLocally = () => {
    if (!selectedUserToAdd) return;
    const userObj = users.find(u => String(u.user_id) === String(selectedUserToAdd));
    if (userObj && !selectedMembers.find(m => m.user_id === userObj.user_id)) {
      setSelectedMembers([...selectedMembers, userObj]);
    }
    setSelectedUserToAdd('');
  };

  const removeMemberLocally = (userId) => {
    setSelectedMembers(selectedMembers.filter(m => m.user_id !== userId));
    if (String(leaderId) === String(userId)) setLeaderId('');
  };

  // 2. Orchestrated Creation Flow
  const handleFinalCreate = async () => {
    if (!name.trim()) return alert("Team name is required");
    setLoading(true);

    try {
      // Step A: Create the base team
      const createRes = await api.post('/teams/create', { name, description });
      const newTeam = createRes.data; 

      // Step B: Add all selected members sequentially
      const memberPromises = selectedMembers.map(member => 
        api.post(`/teams/${newTeam}/add_member`, { user_id: member.user_id })
      );
      await Promise.all(memberPromises);

      // Step C: Assign the leader if specified
      if (leaderId) {
        await api.patch(`/teams/update/${newTeam}`, { 
          assigned_user_id: leaderId 
        });
      }

      onRefresh();
      onClose();
    } catch (err) {
      console.error("Team Creation Orchestration Failed:", err);
      alert("Failed to fully initialize team. Check console for details.");
    } finally {
      setLoading(false);
    }
  };

  const nonMembers = users.filter(u => !selectedMembers.find(m => m.user_id === u.user_id));

  return (
    <div style={styles.overlay}>
      <div style={{ ...styles.modal, width: '550px', maxHeight: '90vh', overflowY: 'auto' }}>
        <h2 style={{ margin: '0 0 8px 0', fontSize: '24px', fontWeight: '800' }}>Create New Team</h2>
        <p style={{ margin: '0 0 24px 0', color: '#64748b', fontSize: '14px' }}>Initialize a team and assign its initial roster.</p>

        <div style={{ marginBottom: '20px' }}>
          <label style={styles.label}>Team Name</label>
          <input style={styles.input} required value={name} onChange={e => setName(e.target.value)} placeholder="Enter team name..." />
        </div>

        <div style={{ marginBottom: '24px' }}>
          <label style={styles.label}>Description</label>
          <textarea style={styles.textarea} value={description} onChange={e => setDescription(e.target.value)} placeholder="What is this team for?" />
        </div>

        {/* --- MEMBER SELECTION SECTION --- */}
        <div style={{ marginBottom: '24px' }}>
          <label style={styles.label}>Add Initial Members</label>
          <div style={styles.memberList}>
            {selectedMembers.length === 0 ? (
              <p style={{ textAlign: 'center', color: '#94a3b8', fontSize: '13px', padding: '10px' }}>No members added yet.</p>
            ) : selectedMembers.map(member => (
              <div key={member.user_id} style={styles.memberItem}>
                <span style={{ fontSize: '14px', fontWeight: '500', flex: 1 }}>{member.username}</span>
                <button onClick={() => removeMemberLocally(member.user_id)} style={styles.deleteBtnFrame}>
                  <Trash2 size={14} />
                </button>
              </div>
            ))}
          </div>

          <div style={styles.addSection}>
            <div style={{ flex: 1 }}>
              <select 
                style={{ ...styles.input, marginTop: 0 }} 
                value={selectedUserToAdd} 
                onChange={e => setSelectedUserToAdd(e.target.value)}
              >
                <option value="">Select users...</option>
                {nonMembers.map(u => (
                  <option key={u.user_id} value={u.user_id}>{u.username}</option>
                ))}
              </select>
            </div>
            <button 
              onClick={addMemberLocally} 
              style={{ ...styles.actionBtnFrame, padding: '10px 16px', background: '#10b981', color: '#fff', border: '1px solid #059669', flex: 0, display: 'flex', alignItems: 'center', gap: '6px' }}
            >
              <UserPlus size={16} /> Add
            </button>
          </div>
        </div>

        {/* --- LEADER ASSIGNMENT --- */}
        <div style={{ marginBottom: '32px' }}>
          <label style={styles.label}>Select Initial Team Lead</label>
          <select style={styles.input} value={leaderId} onChange={e => setLeaderId(e.target.value)}>
            <option value="">No leader assigned yet</option>
            {selectedMembers.map(m => (
              <option key={m.user_id} value={m.user_id}>{m.username}</option>
            ))}
          </select>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <button style={styles.btnCancel} onClick={onClose} disabled={loading}>Cancel</button>
          <button 
            style={{ ...styles.btnSave, opacity: loading ? 0.7 : 1 }} 
            onClick={handleFinalCreate}
            disabled={loading}
          >
            {loading ? "Initializing..." : "Create Team"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default TeamCreateOverlay;