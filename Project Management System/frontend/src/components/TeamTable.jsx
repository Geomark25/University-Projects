import React from 'react';
import { Trash2 } from 'lucide-react';
import { styles } from './adminStyles';

const TeamTable = ({ data, users, onEdit, onDelete }) => {
  const getLeaderName = (userId) => {
    const leader = users.find(u => u.user_id === userId);
    return leader ? leader.username : "Unassigned";
  };

  const handleDelete = (team) => {
    if (window.confirm(`Are you sure you want to delete the team "${team.name}"?`)) {
      onDelete(team.id);
    }
  };

  return (
    <table style={styles.table}>
      <thead>
        <tr>
          <th style={styles.th}>Team Name</th>
          <th style={styles.th}>Description</th>
          <th style={styles.th}>Team Leader</th>
          <th style={{ ...styles.th, textAlign: 'right' }}>Action</th>
        </tr>
      </thead>
      <tbody>
        {data.map(t => (
          <tr key={t.id} style={styles.tr}>
            <td style={{ ...styles.td, fontWeight: '600' }}>{t.name}</td>
            <td style={styles.td}>
              <div style={styles.truncate} title={t.description}>{t.description || "No description."}</div>
            </td>
            <td style={styles.td}>
              <span style={leaderBadgeStyle(t.assigned_user_id)}>{getLeaderName(t.assigned_user_id)}</span>
            </td>
            <td style={{ ...styles.td, textAlign: 'right' }}>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', alignItems: 'center' }}>
                <button onClick={() => onEdit(t)} style={styles.actionBtnFrame}>Edit Team</button>
                <button onClick={() => handleDelete(t)} style={styles.deleteBtnFrame} title="Delete Team">
                  <Trash2 size={16} />
                </button>
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

const leaderBadgeStyle = (hasLeader) => ({
  padding: '4px 10px',
  borderRadius: '8px',
  fontSize: '12px',
  fontWeight: '700',
  background: hasLeader ? '#eff6ff' : '#f8fafc',
  color: hasLeader ? '#2563eb' : '#94a3b8',
  border: `1px solid ${hasLeader ? '#dbeafe' : '#e2e8f0'}`
});

export default TeamTable;