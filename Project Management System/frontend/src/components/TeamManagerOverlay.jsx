import React, { useState, useEffect } from 'react';
import { Trash2, UserPlus } from 'lucide-react';
import api from '../api/axiosInstance';
import { styles } from './adminStyles';

const TeamManagerOverlay = ({ team, users, onClose, onRefresh }) => {
  const [name, setName] = useState(team.name);
  const [description, setDescription] = useState(team.description || "");
  const [assignedUserId, setAssignedUserId] = useState("");
  
  // Staging state for membership [cite: 2026-01-09]
  const [currentMembers, setCurrentMembers] = useState([]);
  const [originalMemberIds, setOriginalMemberIds] = useState([]);
  
  const [selectedUserToAdd, setSelectedUserToAdd] = useState("");
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => { 
    fetchInitialData(); 
  }, [team.id]);

  const fetchInitialData = async () => {
    try {
      const res = await api.get(`/teams/${team.id}/members`);
      const { members, assigned_id } = res.data; 

      // Initialize leader state
      if (assigned_id !== undefined) {
        setAssignedUserId(assigned_id ? String(assigned_id) : "");
      }

      if (members && members.length > 0) {
        const userRes = await api.get('/users/get_by_id', {
          params: { ids: members },
          paramsSerializer: { indexes: null }
        });
        const membersData = userRes.data || [];
        setCurrentMembers(membersData);
        setOriginalMemberIds(membersData.map(m => m.user_id));
      }
    } catch (err) {
      console.error("Error loading team data:", err);
    } finally {
      setLoading(false);
    }
  };

  // LOCAL ACTIONS: No API calls here [cite: 2026-01-09]
  const stageAddMember = () => {
    if (!selectedUserToAdd) return;
    const userObj = users.find(u => String(u.user_id) === String(selectedUserToAdd));
    if (userObj && !currentMembers.find(m => m.user_id === userObj.user_id)) {
      setCurrentMembers([...currentMembers, userObj]);
    }
    setSelectedUserToAdd("");
  };

  const stageRemoveMember = (userId) => {
    setCurrentMembers(currentMembers.filter(m => m.user_id !== userId));
    if (String(assignedUserId) === String(userId)) setAssignedUserId("");
  };

  // ORCHESTRATED SAVE: Commit all changes at once
  const handleSaveChanges = async () => {
    setIsSaving(true);
    try {
      const currentMemberIds = currentMembers.map(m => m.user_id);
      
      const toAdd = currentMemberIds.filter(id => !originalMemberIds.includes(id));
      const toRemove = originalMemberIds.filter(id => !currentMemberIds.includes(id));

      // 1. POST: Add New Members FIRST (and wait for it to finish)
      // This ensures new members exist in the team before you try to assign them as leader in step 2.
      await Promise.all(toAdd.map(id => api.post(`/teams/${team.id}/add_member`, { user_id: id })));

      // 2. & 3. PATCH and DELETE: Fire these requests now
      // We group them in one Promise.all at the end to ensure the UI doesn't close until they are done.
      const remainingOperations = [
        // 2. PATCH: Update Team Details
        api.patch(`/teams/update/${team.id}`, { 
          name, 
          description, 
          assigned_user_id: assignedUserId ? parseInt(assignedUserId) : null 
        }),
        // 3. DELETE: Remove Old Members
        ...toRemove.map(id => api.delete(`/teams/${team.id}/delete_member`, { data: { user_id: id } }))
      ];

      await Promise.all(remainingOperations);
      
      onRefresh();
      onClose();
    } catch (err) { 
      console.error("Save failed:", err);
      alert("Failed to commit changes to the database."); 
    } finally {
      setIsSaving(false);
    }
  };

  const nonMembers = users.filter(u => !currentMembers.find(m => m.user_id === u.user_id));

  return (
    <div style={styles.overlay}>
      <div style={{ ...styles.modal, width: '500px', opacity: isSaving ? 0.7 : 1 }}>
        <h2 style={{ margin: '0 0 8px 0', fontSize: '24px', fontWeight: '800' }}>Team Settings</h2>
        <p style={{ margin: '0 0 24px 0', color: '#64748b', fontSize: '14px' }}>Staged changes will apply only upon saving.</p>

        <div style={{ marginBottom: '20px' }}>
          <label style={styles.label}>Team Name</label>
          <input style={styles.input} value={name} onChange={e => setName(e.target.value)} disabled={isSaving} />
        </div>

        <div style={{ marginBottom: '24px' }}>
          <label style={styles.label}>Description</label>
          <textarea style={styles.textarea} value={description} onChange={e => setDescription(e.target.value)} disabled={isSaving} />
        </div>

        <div style={{ marginBottom: '24px' }}>
          <label style={styles.label}>Current Roster (Staged)</label>
          <div style={styles.memberList}>
            {loading ? (
              <p style={{ textAlign: 'center', color: '#94a3b8' }}>Loading...</p>
            ) : currentMembers.map(member => (
              <div key={member.user_id} style={styles.memberItem}>
                <span style={{ fontSize: '14px', fontWeight: '500', flex: 1 }}>{member.username}</span>
                <button onClick={() => stageRemoveMember(member.user_id)} style={styles.deleteBtnFrame} disabled={isSaving}>
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
                disabled={isSaving}
              >
                <option value="">Select member to add...</option>
                {nonMembers.map(u => (
                  <option key={u.user_id} value={u.user_id}>{u.username}</option>
                ))}
              </select>
            </div>
            <button 
              onClick={stageAddMember} 
              disabled={isSaving}
              style={{ ...styles.actionBtnFrame, padding: '10px 16px', background: '#10b981', color: '#fff', border: '1px solid #059669', flex: 0, display: 'flex', alignItems: 'center', gap: '6px' }}
            >
              <UserPlus size={16} /> Add
            </button>
          </div>
        </div>

        <div style={{ marginBottom: '32px' }}>
          <label style={styles.label}>Designated Team Lead</label>
          <select 
            style={styles.input} 
            value={assignedUserId} 
            onChange={e => setAssignedUserId(e.target.value)}
            disabled={isSaving}
          >
            <option value="">Unassigned</option>
            {currentMembers.map(m => (
              <option key={m.user_id} value={String(m.user_id)}>{m.username}</option>
            ))}
          </select>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <button style={styles.btnCancel} onClick={onClose} disabled={isSaving}>Cancel</button>
          <button style={styles.btnSave} onClick={handleSaveChanges} disabled={isSaving}>
            {isSaving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default TeamManagerOverlay;