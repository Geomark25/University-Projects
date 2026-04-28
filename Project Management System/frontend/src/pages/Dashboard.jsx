import React, { useState, useEffect } from 'react';
import api from '../api/axiosInstance';
import { useAuth } from '../context/AuthContext'; // Import useAuth for deauthorization
import { styles } from '../components/adminStyles';
import { 
  LayoutDashboard, Users, CheckCircle, Clock, ListTodo, 
  Calendar, AlertCircle, CheckCircle2, BarChart3 
} from 'lucide-react';
import { BarChart, Bar, XAxis, Tooltip, ResponsiveContainer, Cell, YAxis, CartesianGrid } from 'recharts';
import TaskViewOverlay from '../components/TaskViewOverlay';
import NotificationBell from '../components/NotificationBell'; // Import Notification Component

const Dashboard = () => {
  const { logout } = useAuth(); // Hook to handle logout
  const [stats, setStats] = useState({ teams: 0, todo: 0, inProgress: 0, done: 0 });
  const [myTasks, setMyTasks] = useState([]);
  const [teams, setTeams] = useState([]);
  const [users, setUsers] = useState([]);
  const [notifications, setNotifications] = useState([]); // State for notifications
  const [sortBy, setSortBy] = useState('priority');
  const [selectedTask, setSelectedTask] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchDashboardData = async () => {
    try {
      // Added /notifications to the parallel fetch
      const [teamsRes, tasksRes, usersRes, notifRes] = await Promise.all([
        api.get('/teams/my_teams'), 
        api.get('/tasks/my_tasks'),
        api.get('/users/all'),
        api.get('/tasks/notifications')
      ]);
      
      const tasks = tasksRes.data || [];
      const fetchedTeams = teamsRes.data || [];
      const fetchedUsers = Array.isArray(usersRes.data) ? usersRes.data : [];

      setTeams(fetchedTeams);
      setMyTasks(tasks);
      setUsers(fetchedUsers);
      setNotifications(notifRes.data || []); // Store notifications

      setStats({
        teams: fetchedTeams.length,
        todo: tasks.filter(t => t.state === 'to_do').length,
        inProgress: tasks.filter(t => t.state === 'in_progress').length,
        done: tasks.filter(t => t.state === 'done').length,
      });

    } catch (err) { 
      console.error("Dashboard refresh error:", err);
      
      // --- IMMEDIATE DEAUTHORIZATION LOGIC ---
      // If the backend returns 401 (Unauthorized) or 403 (Forbidden), 
      // it means the user was deleted or deactivated. Log them out immediately.
      if (err.response && (err.response.status === 401 || err.response.status === 403)) {
        logout(); 
        window.location.href = '/login'; // Force redirect to login
      }
    } finally { 
      setLoading(false); 
    }
  };

  useEffect(() => { 
    fetchDashboardData(); 
  }, []);

  const handleUpdateState = async (taskId, newState) => {
    try {
      await api.patch(`/tasks/${taskId}`, { state: newState });
      fetchDashboardData();
      if (selectedTask?.id === taskId) {
        setSelectedTask(prev => ({ ...prev, state: newState }));
      }
    } catch (err) {
      console.error("State update failed:", err);
    }
  };

  const getSortedActiveTasks = () => {
    const priorityWeight = { 'HIGH': 3, 'MEDIUM': 2, 'LOW': 1 };
    const activeTasks = myTasks.filter(t => t.state !== 'done');
    
    return activeTasks.sort((a, b) => {
      if (sortBy === 'priority') {
        const weightA = priorityWeight[a.priority?.toUpperCase()] || 0;
        const weightB = priorityWeight[b.priority?.toUpperCase()] || 0;
        return weightB !== weightA ? weightB - weightA : b.id - a.id;
      } else {
        const dateA = a.deadline ? new Date(a.deadline).getTime() : Infinity;
        const dateB = b.deadline ? new Date(b.deadline).getTime() : Infinity;
        return dateA !== dateB ? dateA - dateB : b.id - a.id;
      }
    });
  };

  const doneTasks = myTasks.filter(t => t.state === 'done');

  if (loading) return <div style={{ padding: '60px', textAlign: 'center', fontWeight: '900' }}>INITIALIZING OPERATIONAL DATA...</div>;

  return (
    <div style={styles.container}>
      {/* SECTION 1: HEADER & STATS */}
      <div style={{ marginBottom: '30px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1 style={{ margin: 0, color: '#0f172a', fontWeight: '900', display: 'flex', alignItems: 'center', gap: '12px' }}>
          <LayoutDashboard size={32} /> Operational Overview
        </h1>
        
        {/* Notification Bell Integrated Here */}
        <NotificationBell 
          notifications={notifications} 
          onRefresh={fetchDashboardData} 
        />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '20px', marginBottom: '30px' }}>
        <StatCard icon={<Users color="#1d4ed8"/>} label="Teams" value={stats.teams} />
        <StatCard icon={<ListTodo color="#475569"/>} label="To Do" value={stats.todo} />
        <StatCard icon={<Clock color="#2563eb"/>} label="In Progress" value={stats.inProgress} />
        <StatCard icon={<CheckCircle color="#059669"/>} label="Done" value={stats.done} />
      </div>

      {/* SECTION 2: ANALYTICS CHART */}
      <div style={{ ...styles.card, marginBottom: '30px', padding: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '20px' }}>
          <BarChart3 size={20} color="#64748b" />
          <h3 style={{ margin: 0, fontWeight: '800' }}>Task Lifecycle Distribution</h3>
        </div>
        <div style={{ height: '250px' }}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={[
              { name: 'To Do', v: stats.todo },
              { name: 'In Progress', v: stats.inProgress },
              { name: 'Done', v: stats.done }
            ]}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
              <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fontWeight: 700, fontSize: 12}} />
              <YAxis axisLine={false} tickLine={false} tick={{fontWeight: 700, fontSize: 12}} />
              <Tooltip cursor={{fill: '#f8fafc'}} contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
              <Bar dataKey="v" barSize={60} radius={[6, 6, 0, 0]}>
                <Cell fill="#94a3b8" />
                <Cell fill="#2563eb" />
                <Cell fill="#059669" />
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* SECTION 3: OPERATIONAL LISTS */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px' }}>
        {/* ACTIVE TASKS */}
        <div style={styles.card}>
          <div style={{ ...styles.toolbar, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h3 style={{ fontWeight: '800', margin: 0 }}>Active Tasks</h3>
              <span style={{ fontSize: '11px', fontWeight: '700', color: '#64748b' }}>{getSortedActiveTasks().length} Pending</span>
            </div>
            <div style={{ display: 'flex', background: '#f1f5f9', padding: '4px', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
              <button onClick={() => setSortBy('priority')} style={sortBtnStyle(sortBy === 'priority')}><AlertCircle size={14} /> Priority</button>
              <button onClick={() => setSortBy('deadline')} style={sortBtnStyle(sortBy === 'deadline')}><Calendar size={14} /> Deadline</button>
            </div>
          </div>
          <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
            {getSortedActiveTasks().map(t => (
              <div key={t.id} onClick={() => setSelectedTask(t)} style={taskRowStyle}>
                <div style={{ display: 'flex', gap: '15px', alignItems: 'center' }}>
                  <div style={priorityIndicator(t.priority)} />
                  <div>
                    <div style={{ fontWeight: '800', color: '#0f172a' }}>{t.title}</div>
                    <div style={{ fontSize: '11px', color: '#64748b', fontWeight: '700', marginTop: '2px', display: 'flex', gap: '10px' }}>
                      <span>#{t.id}</span>
                      {t.deadline && <span style={{ display: 'flex', alignItems: 'center', gap: '3px' }}><Clock size={10}/> {new Date(t.deadline).toLocaleDateString()}</span>}
                    </div>
                  </div>
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <span style={priorityBadge(t.priority)}>{t.priority}</span>
                  <span style={stateBadge(t.state)}>{t.state?.replace('_', ' ')}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* DONE TASKS */}
        <div style={styles.card}>
          <div style={styles.toolbar}>
            <h3 style={{ fontWeight: '800', margin: 0 }}>Completed History</h3>
            <span style={{ fontSize: '11px', fontWeight: '700', color: '#059669' }}>{doneTasks.length} Accomplished</span>
          </div>
          <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
            {doneTasks.length === 0 ? (
              <div style={{ padding: '40px', textAlign: 'center', color: '#94a3b8', fontWeight: '700' }}>No completed tasks.</div>
            ) : (
              doneTasks.map(t => (
                <div key={t.id} onClick={() => setSelectedTask(t)} style={{ ...taskRowStyle, opacity: 0.8 }}>
                  <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                    <CheckCircle2 size={18} color="#059669" />
                    <div>
                      <div style={{ fontWeight: '700', color: '#475569', textDecoration: 'line-through' }}>{t.title}</div>
                      <div style={{ fontSize: '10px', color: '#94a3b8', fontWeight: '600' }}>ID: {t.id}</div>
                    </div>
                  </div>
                  <span style={{ ...stateBadge('done'), background: '#f0fdf4' }}>DONE</span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {selectedTask && (
        <TaskViewOverlay 
          task={selectedTask} 
          users={users} 
          teams={teams}
          onUpdate={handleUpdateState} 
          onClose={() => setSelectedTask(null)}
          isLeader={teams.find(t => t.id === selectedTask.team_id)?.my_role === 'LEADER'} 
        />
      )}
    </div>
  );
};

// --- Styles ---

const taskRowStyle = {
  padding: '15px 20px', borderBottom: '1px solid #e2e8f0', cursor: 'pointer', display: 'flex', 
  justifyContent: 'space-between', alignItems: 'center', transition: 'background 0.2s'
};

const sortBtnStyle = (isActive) => ({
  display: 'flex', alignItems: 'center', gap: '5px', padding: '6px 12px', border: 'none', borderRadius: '6px',
  fontSize: '11px', fontWeight: '800', cursor: 'pointer', background: isActive ? '#fff' : 'transparent',
  color: isActive ? '#0f172a' : '#64748b', boxShadow: isActive ? '0 1px 3px rgba(0,0,0,0.1)' : 'none'
});

const priorityIndicator = (p) => {
  const colors = { HIGH: '#ef4444', MEDIUM: '#f59e0b', LOW: '#10b981' };
  return { width: '4px', height: '30px', borderRadius: '2px', background: colors[p?.toUpperCase()] || '#cbd5e1' };
};

const priorityBadge = (p) => {
  const colors = { HIGH: { bg: '#fee2e2', text: '#991b1b' }, MEDIUM: { bg: '#fef9c3', text: '#854d0e' }, LOW: { bg: '#dcfce7', text: '#166534' } };
  const theme = colors[p?.toUpperCase()] || { bg: '#f1f5f9', text: '#475569' };
  return { padding: '4px 8px', borderRadius: '4px', fontSize: '9px', fontWeight: '900', background: theme.bg, color: theme.text };
};

const stateBadge = (state) => ({
  padding: '4px 8px', borderRadius: '4px', fontSize: '9px', fontWeight: '900', textTransform: 'uppercase',
  background: state === 'done' ? '#dcfce7' : '#f1f5f9', color: state === 'done' ? '#166534' : '#475569', border: `1px solid ${state === 'done' ? '#10b981' : '#cbd5e1'}`
});

const StatCard = ({ icon, label, value }) => (
  <div style={{ ...styles.card, padding: '24px', display: 'flex', alignItems: 'center', gap: '20px', border: '2px solid #94a3b8' }}>
    <div style={{ background: '#f1f5f9', padding: '12px', borderRadius: '10px' }}>{icon}</div>
    <div>
      <div style={{ fontSize: '13px', fontWeight: '700', color: '#64748b' }}>{label}</div>
      <div style={{ fontSize: '26px', fontWeight: '900', color: '#0f172a' }}>{value}</div>
    </div>
  </div>
);

export default Dashboard;