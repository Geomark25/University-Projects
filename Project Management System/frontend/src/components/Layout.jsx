import React from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate, Link, useLocation } from 'react-router-dom';

const Layout = ({ children }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/auth');
  };

  // Helper for active link styling
  const getLinkStyle = (path) => ({
    textDecoration: 'none',
    color: location.pathname === path ? 'white' : '#bdc3c7',
    fontWeight: location.pathname === path ? '700' : '500',
    fontSize: '14px',
    padding: '6px 12px',
    borderRadius: '6px',
    background: location.pathname === path ? 'rgba(255,255,255,0.1)' : 'transparent',
    transition: 'all 0.2s'
  });

  return (
    <div className="app-container" style={{ minHeight: '100vh', backgroundColor: '#f8fafc' }}>
      <header style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '12px 40px',
        backgroundColor: '#1e293b', // Matching your AdminPanel primary colors
        color: 'white',
        boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '40px' }}>
          <div className="brand" style={{ fontWeight: '800', fontSize: '1.4rem', letterSpacing: '-0.5px' }}>
            Project Manager
          </div>

          {/* --- NAVIGATION LINKS --- */}
          <nav style={{ display: 'flex', gap: '10px' }}>
            <Link to="/dashboard" style={getLinkStyle('/dashboard')}>Dashboard</Link>
            <Link to="/teams" style={getLinkStyle('/teams')}>My Teams</Link>
            <Link to="/account" style={getLinkStyle('/account')}>Account</Link>
            
            {/* Conditional Admin Link */}
            {user?.role === 'ADMIN' && (
              <Link to="/admin" style={{ ...getLinkStyle('/admin'), color: '#fbbf24' }}>
                Admin Panel
              </Link>
            )}
          </nav>
        </div>

        <div className="user-controls" style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <span style={{ fontSize: '14px', color: '#94a3b8' }}>
            Logged in as <strong style={{ color: 'white' }}>{user?.username}</strong>
          </span>
          <button 
            onClick={handleLogout}
            style={{
              backgroundColor: 'transparent',
              color: '#f87171',
              border: '1px solid #7f1d1d',
              padding: '6px 15px',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '13px',
              fontWeight: '600'
            }}
          >
            Logout
          </button>
        </div>
      </header>

      <main style={{ padding: '40px auto', maxWidth: '1200px', margin: '0 auto' }}>
        {children}
      </main>
    </div>
  );
};

export default Layout;