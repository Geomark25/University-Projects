import React, { useState, useEffect } from 'react';
import api from '../api/axiosInstance';
import { styles } from './adminStyles';

const TeamViewOverlay = ({ team, users, onClose }) => {
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMembers = async () => {
      try {
        // Matches @app.get("/{team_id}/members") in teamService.py
        const res = await api.get(`/teams/${team.id}/members`);
        const memberIds = res.data || [];
        
        // Filter the existing users list to show member names
        const memberData = users.filter(u => memberIds.includes(u.user_id));
        setMembers(memberData);
      } catch (err) {
        console.error("Error loading team members", err);
      } finally {
        setLoading(false);
      }
    };
    fetchMembers();
  }, [team.id, users]);

  const leader = users.find(u => String(u.user_id) === String(team.assigned_user_id));

  return (
    <div style={styles.overlay}>
      <div style={{ ...styles.modal, width: '450px' }}>
        <h2 style={{ fontWeight: '900', borderBottom: '3px solid #0f172a', paddingBottom: '10px' }}>
          {team.name}
        </h2>
        
        <div style={{ marginTop: '20px' }}>
          <label style={styles.label}>Description</label>
          <p style={{ fontSize: '14px', color: '#334155', background: '#f8fafc', padding: '12px', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
            {team.description || "No description provided."}
          </p>
        </div>

        <div style={{ marginTop: '20px' }}>
          <label style={styles.label}>Team Leader</label>
          <div style={{ fontWeight: '700', color: '#1e40af' }}>
            {leader ? leader.username : "Unassigned"}
          </div>
        </div>

        <div style={{ marginTop: '20px' }}>
          <label style={styles.label}>Members ({members.length})</label>
          <div style={{ maxHeight: '150px', overflowY: 'auto', background: '#f1f5f9', padding: '10px', borderRadius: '8px' }}>
            {loading ? <p>Loading...</p> : members.map(m => (
              <div key={m.user_id} style={{ fontSize: '13px', padding: '4px 0', borderBottom: '1px solid #e2e8f0', fontWeight: '600' }}>
                • {m.username}
              </div>
            ))}
          </div>
        </div>

        <button onClick={onClose} style={{ ...styles.btnCancel, width: '100%', marginTop: '25px' }}>
          Close View
        </button>
      </div>
    </div>
  );
};

export default TeamViewOverlay;