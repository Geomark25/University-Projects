import React, { useState, useEffect, useCallback } from 'react';
import ReactDOM from 'react-dom'; // Import ReactDOM
import api from '../api/axiosInstance';
import { X, Plus, ClipboardList, Loader2, Clock } from 'lucide-react';
import TaskCreateOverlay from './TaskCreateOverlay';
import TaskViewOverlay from './TaskViewOverlay';

const TaskOverlay = ({ team, isLeader, onClose, users }) => {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showCreate, setShowCreate] = useState(false);
  const [selectedTask, setSelectedTask] = useState(null);

  const fetchTasks = useCallback(async () => {
    setLoading(true);
    try {
      const res = await api.get(`/tasks/${team.id}/tasks`);
      setTasks(res.data || []);
    } catch (err) {
      setError('Could not load tasks for this team.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [team.id]);

  useEffect(() => {
    fetchTasks();
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [fetchTasks]);

  const handleCloseDetail = () => {
    setSelectedTask(null);
    fetchTasks();
  };

  // The content of the modal
  const overlayContent = (
    <div style={overlayStyles.backdrop} onClick={onClose}>
      <div style={overlayStyles.modal} onClick={(e) => e.stopPropagation()}>
        {showCreate ? (
          <TaskCreateOverlay 
            team={team}
            users={users}
            onClose={() => setShowCreate(false)} 
            onRefresh={fetchTasks} 
          />
        ) : selectedTask ? (
          <TaskViewOverlay 
            task={selectedTask} 
            users={users || []}
            teams={[team]}
            isLeader={isLeader}
            onClose={handleCloseDetail} 
          />
        ) : (
          <>
            <div style={overlayStyles.header}>
              <div>
                <h2 style={{ margin: 0, fontWeight: '900', color: '#0f172a' }}>{team.name} Tasks</h2>
                <p style={{ margin: 0, fontSize: '12px', color: '#64748b' }}>Project Overview</p>
              </div>
              <button onClick={onClose} style={overlayStyles.closeBtn}><X size={24} /></button>
            </div>

            <div style={overlayStyles.body}>
              {isLeader && (
                <button 
                  style={overlayStyles.addTaskBtn}
                  onClick={() => setShowCreate(true)}
                >
                  <Plus size={18} /> Create New Task
                </button>
              )}

              {error && <div style={{ color: '#ef4444', fontWeight: '600', marginBottom: '10px' }}>{error}</div>}

              {loading ? (
                <div style={overlayStyles.centered}><Loader2 className="animate-spin" /></div>
              ) : tasks.length === 0 ? (
                <div style={overlayStyles.emptyState}>
                  <ClipboardList size={48} color="#cbd5e1" />
                  <p>No tasks found for this organization.</p>
                </div>
              ) : (
                <div style={overlayStyles.taskList}>
                  {tasks.map((task) => (
                    <div 
                      key={task.id} 
                      style={overlayStyles.taskCard}
                      onClick={() => setSelectedTask(task)}
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <div style={{ flex: 1 }}>
                          <h4 style={{ margin: 0, fontWeight: '800', color: '#0f172a' }}>{task.title}</h4>
                          <p style={{ fontSize: '13px', color: '#475569', marginTop: '4px', marginBottom: '12px' }}>
                            {task.description || "No description provided."}
                          </p>
                        </div>
                        <span style={priorityBadgeStyle(task.priority)}>{task.priority}</span>
                      </div>

                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px solid #f1f5f9', paddingTop: '12px' }}>
                        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                          <span style={stateBadgeStyle(task.state)}>{task.state?.replace('_', ' ')}</span>
                          <div style={{ 
                            display: 'flex', alignItems: 'center', gap: '4px', 
                            fontSize: '11px', fontWeight: '700',
                            color: task.deadline ? '#64748b' : '#94a3b8'
                          }}>
                            <Clock size={12} />
                            {task.deadline ? new Date(task.deadline).toLocaleDateString() : 'No Deadline'}
                          </div>
                        </div>
                        <span style={{ fontSize: '10px', color: '#94a3b8', fontWeight: '600' }}>ID: {task.id}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );

  // Render using Portal to document.body
  return ReactDOM.createPortal(overlayContent, document.body);
};

// --- Styles ---

const priorityBadgeStyle = (priority) => {
  const colors = {
    HIGH: { bg: '#fee2e2', text: '#991b1b', border: '#fecaca' },
    MEDIUM: { bg: '#fef9c3', text: '#854d0e', border: '#fef08a' },
    LOW: { bg: '#dcfce7', text: '#166534', border: '#bbf7d0' }
  };
  const theme = colors[priority?.toUpperCase()] || { bg: '#f1f5f9', text: '#475569', border: '#e2e8f0' };
  return {
    padding: '4px 8px', borderRadius: '6px', fontSize: '10px', fontWeight: '900',
    backgroundColor: theme.bg, color: theme.text, border: `1px solid ${theme.border}`,
    textTransform: 'uppercase'
  };
};

const stateBadgeStyle = (state) => {
  const isDone = state?.toUpperCase() === 'DONE' || state?.toUpperCase() === 'COMPLETED';
  return {
    fontSize: '10px', fontWeight: '900', padding: '4px 8px', borderRadius: '6px', border: '1px solid',
    textTransform: 'uppercase',
    backgroundColor: isDone ? '#f0fdf4' : '#f8fafc',
    color: isDone ? '#166534' : '#475569',
    borderColor: isDone ? '#bbf7d0' : '#e2e8f0'
  };
};

const overlayStyles = {
  backdrop: { 
    position: 'fixed', 
    top: 0, 
    left: 0, 
    width: '100vw', 
    height: '100vh', 
    background: 'rgba(15, 23, 42, 0.6)', 
    backdropFilter: 'blur(4px)', 
    display: 'flex', 
    alignItems: 'center', 
    justifyContent: 'center', 
    zIndex: 9999 // Very high z-index
  },
  modal: { 
    background: '#fff', 
    width: '95%', 
    maxWidth: '550px', 
    borderRadius: '16px', 
    display: 'flex', 
    flexDirection: 'column', 
    maxHeight: '85vh', 
    position: 'relative', 
    overflow: 'hidden',
    boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)'
  },
  header: { padding: '24px', borderBottom: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#fff' },
  body: { padding: '24px', overflowY: 'auto', background: '#fff' },
  closeBtn: { background: 'none', border: 'none', cursor: 'pointer', color: '#64748b' },
  addTaskBtn: { width: '100%', padding: '12px', background: '#0f172a', color: '#fff', border: 'none', borderRadius: '8px', fontWeight: '800', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', cursor: 'pointer', marginBottom: '20px' },
  taskList: { display: 'flex', flexDirection: 'column', gap: '16px' },
  taskCard: { padding: '16px', border: '1px solid #e2e8f0', borderRadius: '12px', background: '#fff', cursor: 'pointer', transition: 'all 0.2s', ':hover': { borderColor: '#94a3b8' } },
  emptyState: { textAlign: 'center', padding: '40px 0', color: '#64748b' },
  centered: { display: 'flex', justifyContent: 'center', padding: '20px' }
};

export default TaskOverlay;