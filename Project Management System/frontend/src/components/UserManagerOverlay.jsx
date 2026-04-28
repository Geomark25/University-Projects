import React, { useRef } from 'react';
import api from '../api/axiosInstance';
import { styles } from './adminStyles';

const UserManagerOverlay = ({ user, onClose, onRefresh }) => {
  // 1. Use Refs to hold the DOM elements directly
  const roleRef = useRef();
  const stateRef = useRef();

  const handleUpdate = async () => {
    // 2. Extract values from the dropdowns ONLY at the moment of the click
    const selectedRole = roleRef.current.value;
    const selectedState = stateRef.current.value;

    const payload = {
      user_role: selectedRole,
      user_state: selectedState
    };

    try {
      // 3. Send the newly captured values to the API Gateway
      await api.patch(`/users/update_user/${user.user_id}`, payload);
      onRefresh();
      onClose();
    } catch (err) {
      console.error("Update failed:", err);
      alert("Update failed");
    }
  };

  return (
    <div style={styles.overlay}>
      <div style={styles.modal}>
        <h3>Managing: {user.username}</h3>
        
        <div style={{ marginBottom: '15px' }}>
          <label style={styles.label}>Role</label>
          <select 
            ref={roleRef} 
            style={styles.input} 
            // Sets the initial visual choice based on current user role
            defaultValue={user.user_role || "MEMBER"}
          >
            <option value="MEMBER">MEMBER</option>
            <option value="ADMIN">ADMIN</option>
          </select>
        </div>

        <div style={{ marginBottom: '15px' }}>
          <label style={styles.label}>Status</label>
          <select 
            ref={stateRef} 
            style={styles.input} 
            // If user is currently DELETED, default the visual to ACTIVE
            defaultValue={
              (user.user_state === 'ACTIVE' || user.user_state === 'DEACTIVATED') 
              ? user.user_state 
              : 'ACTIVE'
            }
          >
            <option value="ACTIVE">ACTIVE</option>
            <option value="DEACTIVATED">DEACTIVATED</option>
          </select>
        </div>

        <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
          <button style={styles.btnCancel} onClick={onClose}>Cancel</button>
          <button style={styles.btnSave} onClick={handleUpdate}>Save Changes</button>
        </div>
      </div>
    </div>
  );
};

export default UserManagerOverlay;