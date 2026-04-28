import React, { useState } from 'react';
import api from '../api/axiosInstance';
import { styles } from './adminStyles';

const UserCreateOverlay = ({ onClose, onRefresh }) => {
  const [formData, setFormData] = useState({ 
    username: '', 
    email: '', 
    password: '', 
    first_name: '', 
    last_name: '', 
    role: 'MEMBER', 
    state: 'ACTIVE'
  });
  const [confirmPassword, setConfirmPassword] = useState('');

  const handleCreate = async (e) => {
    e.preventDefault();

    if (formData.password !== confirmPassword) {
      alert("Passwords do not match!");
      return;
    }

    try {
      await api.post('/users/create', formData);
      onRefresh();
      onClose();
    } catch (err) {
      alert("Failed to create user");
    }
  };

  return (
    <div style={styles.overlay}>
      {/* Width increased to 500px to accommodate multiple fields comfortably */}
      <div style={{ ...styles.modal, width: '500px', maxHeight: '90vh', overflowY: 'auto' }}>
        <h2 style={{ margin: '0 0 24px 0', fontSize: '24px', fontWeight: '800' }}>Create User</h2>
        
        <form onSubmit={handleCreate}>
          <div style={{ marginBottom: '20px' }}>
            <label style={styles.label}>Username</label>
            <input 
              style={styles.input}
              required
              value={formData.username}
              onChange={e => setFormData({ ...formData, username: e.target.value })} 
            />
          </div>

          <div style={{ marginBottom: '20px' }}>
            <label style={styles.label}>Email</label>
            <input 
              type="email"
              required
              style={styles.input} 
              value={formData.email}
              pattern="[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
              onChange={e => setFormData({ ...formData, email: e.target.value })} 
            />
          </div>

          <div style={{ display: 'flex', gap: '15px', marginBottom: '20px' }}>
            <div style={{ flex: 1 }}>
              <label style={styles.label}>First Name</label>
              <input 
                style={styles.input} 
                required
                value={formData.first_name}
                onChange={e => setFormData({ ...formData, first_name: e.target.value })} 
              />
            </div>
            <div style={{ flex: 1 }}>
              <label style={styles.label}>Last Name</label>
              <input 
                style={styles.input}
                required
                value={formData.last_name}
                onChange={e => setFormData({ ...formData, last_name: e.target.value })} 
              />
            </div>
          </div>

          <div style={{ marginBottom: '20px' }}>
            <label style={styles.label}>Password</label>
            <input 
              type="password" 
              style={styles.input} 
              required
              minLength={6}
              value={formData.password}
              onChange={e => setFormData({ ...formData, password: e.target.value })} 
            />
          </div>

          <div style={{ marginBottom: '20px' }}>
            <label style={styles.label}>Confirm Password</label>
            <input 
              type="password" 
              style={styles.input} 
              required
              value={confirmPassword}
              onChange={e => setConfirmPassword(e.target.value)} 
            />
          </div>

          <div style={{ display: 'flex', gap: '15px', marginBottom: '32px' }}>
            <div style={{ flex: 1 }}>
              <label style={styles.label}>Role</label>
              <select 
                style={styles.input} 
                value={formData.role}
                onChange={e => setFormData({ ...formData, role: e.target.value })}
              >
                <option value="MEMBER">Member</option>
                <option value="ADMIN">Admin</option>
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={styles.label}>State</label>
              <select 
                style={styles.input} 
                value={formData.state}
                onChange={e => setFormData({ ...formData, state: e.target.value })}
              >
                <option value='ACTIVE'>Active</option>
                <option value='INACTIVE'>Inactive</option>
              </select>
            </div>
          </div>

          <div style={{ display: 'flex', gap: '12px' }}>
            <button type="button" style={styles.btnCancel} onClick={onClose}>Cancel</button>
            <button type="submit" style={styles.btnSave}>Create User</button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default UserCreateOverlay;