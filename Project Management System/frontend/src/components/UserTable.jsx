import React from 'react';
import { Trash2 } from 'lucide-react';
import { styles } from './adminStyles';

const UserTable = ({ data, onEdit, onDelete }) => {
  const handleDelete = (user) => {
    if (window.confirm(`Are you sure you want to delete ${user.username}?`)) {
      onDelete(user.user_id);
    }
  };

  return (
    <table style={styles.table}>
      <thead>
        <tr>
          <th style={styles.th}>Username</th>
          <th style={styles.th}>Role</th>
          <th style={styles.th}>Status</th>
          <th style={{ ...styles.th, textAlign: 'right' }}>Actions</th>
        </tr>
      </thead>
      <tbody>
        {data.map((u) => {
          const isDeleted = u.user_state === 'DELETED';

          return (
            <tr key={u.user_id} style={styles.tr}>
              <td style={{ ...styles.td, fontWeight: '600' }}>{u.username}</td>
              <td style={styles.td}>{u.user_role}</td>
              <td style={{ 
                ...styles.td, 
                color: isDeleted ? '#94a3b8' : (u.user_state === 'ACTIVE' ? '#38a169' : '#dd6b20') 
              }}>
                {u.user_state}
              </td>
              <td style={{ ...styles.td, textAlign: 'right' }}>
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', alignItems: 'center' }}>
                  <button onClick={() => onEdit(u)} style={styles.actionBtnFrame}>Manage</button>
                  <button 
                    onClick={() => handleDelete(u)} 
                    disabled={isDeleted} 
                    style={{ 
                      ...styles.deleteBtnFrame,
                      opacity: isDeleted ? 0.4 : 1,
                      cursor: isDeleted ? 'not-allowed' : 'pointer',
                      filter: isDeleted ? 'grayscale(1)' : 'none'
                    }} 
                    title={isDeleted ? "User already deleted" : "Delete User"}
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
};

export default UserTable;