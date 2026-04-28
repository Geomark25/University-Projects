import React, { useState, useEffect } from 'react';
import api from '../api/axiosInstance';
import { useAuth } from '../context/AuthContext';
import { styles } from '../components/adminStyles';
import { Plus, ListTodo } from 'lucide-react';
import TeamManagerOverlay from '../components/TeamManagerOverlay';
import TeamViewOverlay from '../components/TeamViewOverlay';
import TeamCreateOverlay from '../components/TeamCreateOverlay';
import TaskOverlay from '../components/TaskOverlay';

const Teams = () => {
  const { user } = useAuth();
  const [teams, setTeams] = useState([]);
  const [allUsers, setAllUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [editingTeam, setEditingTeam] = useState(null);
  const [viewingTeam, setViewingTeam] = useState(null);
  const [viewingTasksTeam, setViewingTasksTeam] = useState(null);
  const [showCreate, setShowCreate] = useState(false);

  const fetchData = async () => {
    try {
      const [teamsRes, usersRes] = await Promise.all([
        api.get('/teams/my_teams'),
        api.get('/users/all')
      ]);
      setTeams(teamsRes.data || []);
      setAllUsers(usersRes.data || []);
    } catch (err) {
      setError('Failed to fetch teams.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (user) fetchData();
  }, [user]);

  if (loading) return <div style={{ padding: '40px', fontWeight: '800' }}>LOADING TEAMS...</div>;

  return (
    <div style={styles.container}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <h1 style={{ margin: 0, fontWeight: '900' }}>My Organizations</h1>
        <button
          onClick={() => setShowCreate(true)}
          style={{ ...styles.actionBtnFrame, background: '#0f172a', color: '#fff', display: 'flex', alignItems: 'center', gap: '8px' }}
        >
          <Plus size={18} /> Create New Team
        </button>
      </div>

      {error && <p style={{ color: 'red', fontWeight: '700' }}>{error}</p>}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '20px' }}>
        {teams.map((team) => {
          const isLeader = team.my_role === "LEADER";
          return (
            <div key={team.id} style={styles.card}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <h3 style={{ margin: 0, fontWeight: '800' }}>{team.name}</h3>
                <span style={roleBadgeStyle(isLeader)}>{team.my_role}</span>
              </div>
              <p style={{ color: '#64748b', fontSize: '14px', margin: '15px 0' }}>
                {team.description || "No description provided."}
              </p>
              
              <div style={{ display: 'flex', gap: '10px' }}>
                <button
                  onClick={() => isLeader ? setEditingTeam(team) : setViewingTeam(team)}
                  style={{ 
                    ...styles.actionBtnFrame, 
                    marginTop: '20px', 
                    flex: 1, 
                    background: isLeader ? '#0f172a' : '#f1f5f9', 
                    color: isLeader ? '#fff' : '#0f172a' 
                  }}
                >
                  {isLeader ? 'Manage' : 'Details'}
                </button>

                <button
                  onClick={() => setViewingTasksTeam(team)}
                  style={{ 
                    ...styles.actionBtnFrame, 
                    marginTop: '20px', 
                    padding: '0 15px', 
                    background: '#f8fafc', 
                    border: '1px solid #e2e8f0' 
                  }}
                  title="View Team Tasks"
                >
                  <ListTodo size={18} color="#0f172a" />
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {showCreate && <TeamCreateOverlay onClose={() => setShowCreate(false)} onRefresh={fetchData} users={allUsers} />}
      {editingTeam && <TeamManagerOverlay team={editingTeam} users={allUsers} onClose={() => setEditingTeam(null)} onRefresh={fetchData} />}
      {viewingTeam && <TeamViewOverlay team={viewingTeam} users={allUsers} onClose={() => setViewingTeam(null)} />}
      
      {viewingTasksTeam && (
        <TaskOverlay 
          team={viewingTasksTeam} 
          isLeader={viewingTasksTeam.my_role === "LEADER"}
          users={allUsers}
          onClose={() => setViewingTasksTeam(null)} 
        />
      )}
    </div>
  );
};

const roleBadgeStyle = (isLeader) => ({
  padding: '4px 8px', borderRadius: '6px', fontSize: '10px', fontWeight: '900', textTransform: 'uppercase',
  backgroundColor: isLeader ? '#dbeafe' : '#f1f5f9', color: isLeader ? '#1e40af' : '#475569', border: `1px solid ${isLeader ? '#3b82f6' : '#94a3b8'}`
});

export default Teams;