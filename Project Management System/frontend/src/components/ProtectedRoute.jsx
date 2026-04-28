import React, { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../api/axiosInstance';
import { Loader2 } from 'lucide-react';

const ProtectedRoute = ({ children }) => {
  const { user, loading, logout } = useAuth();
  const [isValidating, setIsValidating] = useState(true);

  useEffect(() => {
    const validateUserStatus = async () => {
      if (loading || !user) {
        setIsValidating(false);
        return;
      }

      try {
        const res = await api.get('/users/get_user');
        const userData = res.data;

        const invalidStates = ['DEACTIVATED', 'DELETED'];

        if (invalidStates.includes(userData.user_state)) {
          console.warn("User access revoked via ProtectedRoute validation");
          logout()
        }
      } catch (err) {
        console.error("Validation failed", err);
        if (err.response && (err.response.status === 401 || err.response.status === 403)) {
          logout();
        }
      } finally {
        setIsValidating(false);
      }
    };

    if (!loading) {
      validateUserStatus();
    }
  }, [user, loading, logout]);

  if (loading || (user && isValidating)) {
    return (
      <div style={{ height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Loader2 className="animate-spin" size={40} color="#0f172a" />
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/auth" replace />;
  }

  return children;
};

export default ProtectedRoute;