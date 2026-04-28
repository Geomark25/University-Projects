import React, { useState, useEffect } from 'react';
import api from '../api/axiosInstance';
import { styles } from '../components/adminStyles';
import UserTable from '../components/UserTable';
import TeamTable from '../components/TeamTable';
import TaskTable from '../components/TaskTable';
import TaskViewOverlay from '../components/TaskViewOverlay';
import TeamManagerOverlay from '../components/TeamManagerOverlay';
import UserManagerOverlay from '../components/UserManagerOverlay';

const AdminPanel = () => {
  const [activeTab, setActiveTab] = useState('users');
  const [users, setUsers] = useState([]);
  const [nonCurrUsers, setNonCurrUsers] = useState([]); 
  const [teams, setTeams] = useState([]);
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  
  const [viewingTask, setViewingTask] = useState(null);
  const [editingTeam, setEditingTeam] = useState(null);
  const [editingUser, setEditingUser] = useState(null);

  const fetchData = async () => {
    setLoading(true);
    try {
      const token = sessionStorage.getItem('access_token');
      const payload = JSON.parse(window.atob(token.split('.')[1]));
      const currID = payload.sub;

      // Endpoints match userService.py, teamService.py, and taskService.py
      const [uRes, tRes, taskRes] = await Promise.all([
        api.get('/users/all'),
        api.get('/teams/all'),
        api.get('/tasks/all')
      ]);

      const allUsers = uRes.data || [];
      const filtered = allUsers.filter(u => String(u.user_id) !== String(currID));

      setNonCurrUsers(allUsers); 
      setUsers(filtered);
      setTeams(tRes.data || []);
      setTasks(taskRes.data || []);
    } catch (err) { console.error("Fetch Error:", err); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchData(); }, []);

  const getFilteredData = () => {
    const s = search.toLowerCase();
    const data = activeTab === 'users' ? users : activeTab === 'teams' ? teams : tasks;
    if (!data) return [];
    if (activeTab === 'users') return data.filter(u => u.username?.toLowerCase().includes(s));
    if (activeTab === 'teams') return data.filter(t => t.name?.toLowerCase().includes(s));
    return data.filter(t => t.title?.toLowerCase().includes(s));
  };

  const handleDeleteEntry = async (type, id) => {
    try {
      // FIXED: Endpoint now matches @app.delete("/delete_by_id/{user_id}") in userService.py
      const endpoint = type === 'users' ? `/users/delete_by_id/${id}` : `/teams/${id}/delete`;
      await api.delete(endpoint);
      fetchData();
    } catch (err) { console.error("Delete Error:", err); }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <div style={styles.toolbar}>
          <div style={styles.tabGroup}>
            <button onClick={() => setActiveTab('users')} style={activeTab === 'users' ? styles.activeTabBtn : styles.tabBtn}>Users</button>
            <button onClick={() => setActiveTab('teams')} style={activeTab === 'teams' ? styles.activeTabBtn : styles.tabBtn}>Teams</button>
            <button onClick={() => setActiveTab('tasks')} style={activeTab === 'tasks' ? styles.activeTabBtn : styles.tabBtn}>All Tasks</button>
          </div>
          <input style={{...styles.input, width: '250px', marginTop: 0}} placeholder="Search..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>

        {loading ? <div style={{padding: '50px', textAlign: 'center', fontWeight: '800'}}>SYNCHRONIZING...</div> : (
          <>
            {activeTab === 'users' && (
              <UserTable 
                data={getFilteredData()} 
                onEdit={(u) => setEditingUser(u)} 
                onDelete={(id) => handleDeleteEntry('users', id)} 
              />
            )}
            {activeTab === 'teams' && (
              <TeamTable 
                data={getFilteredData()} 
                users={nonCurrUsers} 
                onEdit={(t) => setEditingTeam(t)} 
                onDelete={(id) => handleDeleteEntry('teams', id)} 
              />
            )}
            {activeTab === 'tasks' && <TaskTable data={getFilteredData()} onView={setViewingTask} />}
          </>
        )}
      </div>

      {editingUser && (
        <UserManagerOverlay user={editingUser} onClose={() => setEditingUser(null)} onRefresh={fetchData} />
      )}

      {editingTeam && (
        <TeamManagerOverlay team={editingTeam} users={nonCurrUsers} onClose={() => setEditingTeam(null)} onRefresh={fetchData} />
      )}

      {viewingTask && (
        <TaskViewOverlay task={viewingTask} users={nonCurrUsers} teams={teams} onClose={() => setViewingTask(null)} />
      )}
    </div>
  );
};

export default AdminPanel;