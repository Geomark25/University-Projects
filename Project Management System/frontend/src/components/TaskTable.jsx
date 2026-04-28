import React from 'react';
import { styles } from './adminStyles';

const TaskTable = ({ data, onView }) => {
  const getStateBadge = (state) => {
    const colors = state === 'done' ? { bg: '#dcfce7', text: '#166534', border: '#10b981' } : 
                   state === 'in_progress' ? { bg: '#dbeafe', text: '#1e40af', border: '#3b82f6' } : 
                   { bg: '#f1f5f9', text: '#334155', border: '#94a3b8' };
    
    return (
      <span style={{ padding: '4px 10px', borderRadius: '6px', fontSize: '11px', fontWeight: '900', textTransform: 'uppercase', backgroundColor: colors.bg, color: colors.text, border: `2px solid ${colors.border}` }}>
        {state.replace('_', ' ')}
      </span>
    );
  };

  return (
    <div style={{ overflowX: 'auto' }}>
      <table style={styles.table}>
        <thead>
          <tr>
            <th style={styles.th}>Task Title</th>
            <th style={styles.th}>Current State</th>
            <th style={styles.th}>Priority</th>
            <th style={styles.th}>Deadline</th>
            <th style={styles.th}>Actions</th>
          </tr>
        </thead>
        <tbody>
          {data.map((task) => (
            <tr key={task.id} style={styles.tr}>
              <td style={styles.td}><div style={{ fontWeight: '800' }}>{task.title}</div></td>
              <td style={styles.td}>{getStateBadge(task.state)}</td>
              <td style={{ ...styles.td, fontWeight: '800' }}>{task.priority}</td>
              <td style={styles.td}>{task.deadline ? new Date(task.deadline).toLocaleDateString() : '-'}</td>
              <td style={styles.td}><button style={styles.actionBtnFrame} onClick={() => onView(task)}>View</button></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default TaskTable;