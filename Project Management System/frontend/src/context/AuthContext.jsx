import React, { createContext, useState, useEffect, useContext, useRef } from 'react';
import { jwtDecode } from 'jwt-decode';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const timeoutRef = useRef(null);

  const logout = () => {
    sessionStorage.removeItem('access_token');
    setUser(null);
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    window.location.href = '/auth';
  };

  const updateUserInfo = (newData) => {
    setUser(prev => ({
      ...prev,
      ...newData
    }));
  };
  const resetTimer = () => {
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    timeoutRef.current = setTimeout(logout, 60000000);
  };

  useEffect(() => {
    const token = sessionStorage.getItem('access_token');
    if (token) {
      setUser(jwtDecode(token));
      resetTimer();
    }
    setLoading(false);

    // List of activity events to track
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart'];
    
    events.forEach(event => {
      window.addEventListener(event, resetTimer);
    });

    return () => {
      events.forEach(event => {
        window.removeEventListener(event, resetTimer);
      });
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, []);

  const login = (token) => {
    sessionStorage.setItem('access_token', token);
    setUser(jwtDecode(token));
    resetTimer(); // Start timer on login
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading, updateUserInfo}}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);