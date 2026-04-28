import React, { useState, useEffect } from 'react';
import api from '../api/axiosInstance';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';



const User = () => {

const inputStyle = { 
  width: '100%', 
  padding: '10px', 
  marginTop: '5px', 
  borderRadius: '4px', 
  border: '1px solid #ccc',
  boxSizing: 'border-box'
};

const disabledInputStyle = {
  ...inputStyle,
  backgroundColor: '#f5f5f5',
  color: '#000000ff',
  border: '1px solid #e2e8f0'
};

  const { user, logout, updateUserInfo} = useAuth();
  const navigate = useNavigate();
  
  // States for different types of data
  const [formData, setFormData] = useState({ 
    username: '', email: '', first_name: '', last_name: '' 
  });
  const [passwordData, setPasswordData] = useState({new: '', confirm: '' });
  const [isEditing, setIsEditing] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  useEffect(() => {
    const fetchFullProfile = async () => {
      try {
        const response = await api.get(`/users/get_user`);
        
        setFormData({
          username: response.data.username,
          email: response.data.email || '',
          first_name: response.data.first_name || '',
          last_name: response.data.last_name || '',
          user_role: response.data.role,
          user_state: response.data.state
        });
      } catch (err) {
        console.error("Error fetching full profile:", err);
      }
    };

    if (user?.sub) {
      fetchFullProfile();
    }
  }, [user]);

  const handleUpdateProfile = async (e) => {
    e.preventDefault();
    try {
      await api.patch(`/users/update_user`, formData);
      updateUserInfo({username: formData.username})
      setMessage({ type: 'success', text: 'Profile updated successfully!' });
      setIsEditing(false);
    } catch (err) {
      setMessage({ type: 'error', text: err.response?.data?.detail || 'Update failed' });
      console.log(err)
    }
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    if (passwordData.new !== passwordData.confirm) {
      return setMessage({ type: 'error', text: 'New passwords do not match' });
    }
    try {
      await api.patch(`/users/password`, {
        new_password: passwordData.new
      });
      setMessage({ type: 'success', text: 'Password changed successfully!' });
      setPasswordData({new: '', confirm: '' });
    } catch (err) {
      setMessage({ type: 'error', text: err.response?.data?.detail || 'Password change failed' });
    }
  };

  const handleDeleteUser = async (e) => {
  e.preventDefault(); // Fixed: Added parentheses

  const confirmed = window.confirm(
    "Are you sure you want to delete your account? This action cannot be undone."
  );

  if (confirmed) {
    try {
      api.delete('/users/delete');
      await logout();
      navigate('/auth'); 
      
    } catch (err) {
      console.error("Deletion failed:", err);
      setMessage({ 
        type: 'error', 
        text: err.response?.data?.detail || 'Could not delete account.' 
      });
    }
  }
};

  return (
    <div style={{ maxWidth: '700px', margin: '0 auto', paddingBottom: '50px' }}>
      <h2>User Profile</h2>
      {message.text && (
        <div style={{ color: message.type === 'error' ? '#e53e3e' : '#38a169', marginBottom: '15px', fontWeight: 'bold' }}>
          {message.text}
        </div>
      )}

      {/* Profile Information Section */}
      <section style={{ border: '1px solid #ddd', padding: '25px', borderRadius: '8px', marginBottom: '20px' }}>
        <h3>Personal Information</h3>
        <form onSubmit={handleUpdateProfile}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
            <div>
              <label>First Name:</label>
              <input type="text" required disabled={!isEditing} value={formData.first_name}
                onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                style={inputStyle} />
            </div>
            <div>
              <label>Last Name:</label>
              <input type="text" required disabled={!isEditing} value={formData.last_name}
                onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                style={inputStyle} />
            </div>
            <div>
              <label>Username:</label>
              <input type="text" required disabled={!isEditing} value={formData.username}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                style={inputStyle} />
            </div>
            <div>
              <label>Email:</label>
              <input type="email" required disabled={!isEditing} value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                style={inputStyle} />
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginTop: '15px', opacity: 0.7 }}>
            <div>
              <label>Role (Read-only):</label>
              <input type="text" disabled value={user?.role} style={disabledInputStyle} />
            </div>
            <div>
              <label>Account State (Read-only):</label>
              <input type="text" disabled value={user?.state || 'ACTIVE'} style={disabledInputStyle} />
            </div>
          </div>

          <div style={{ marginTop: '20px' }}>
            {isEditing ? (
              <>
                <button key="save" type="submit" style={btnPrimary}>Save Profile</button>
                <button key="cancel" type="button" onClick={() => setIsEditing(false)} style={btnSecondary}>Cancel</button>
              </>
            ) : (
              <button key="edit" type="button" onClick={() => setIsEditing(true)} style={btnPrimary}>Edit Details</button>
            )}
          </div>
        </form>
      </section>

      {/* Password Change Section */}
      <section style={{ border: '1px solid #ddd', padding: '25px', borderRadius: '8px', marginBottom: '20px' }}>
        <h3>Change Password</h3>
        <form onSubmit={handleChangePassword}>
          <div style={{ marginBottom: '10px' }}>
            <label>New Password:</label>
            <input type="password" value={passwordData.new}
              onChange={(e) => setPasswordData({ ...passwordData, new: e.target.value })}
              style={inputStyle} required />
          </div>
          <div style={{ marginBottom: '20px' }}>
            <label>Confirm New Password:</label>
            <input type="password" value={passwordData.confirm}
              onChange={(e) => setPasswordData({ ...passwordData, confirm: e.target.value })}
              style={inputStyle} required />
          </div>
          <button type="submit" style={btnPrimary}>Update Password</button>
        </form>
      </section>

      {/* Delete Section */}
      <button 
        onClick={handleDeleteUser}
        style={{ color: '#e53e3e', background: 'none', border: 'none', cursor: 'pointer', textDecoration: 'underline' }}
      >
        Delete Account permanently
      </button>
    </div>
  );
};

// Simple Styles
const inputStyle = { width: '100%', padding: '10px', marginTop: '5px', borderRadius: '4px', border: '1px solid #ccc' };
const btnPrimary = { backgroundColor: '#2b6cb0', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '4px', cursor: 'pointer', marginRight: '10px' };
const btnSecondary = { backgroundColor: '#718096', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '4px', cursor: 'pointer' };

export default User;