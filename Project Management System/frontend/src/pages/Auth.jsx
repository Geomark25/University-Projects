import React, { useState } from 'react';
import api from '../api/axiosInstance';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Auth = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [message, setMessage] = useState({ text: '', type: '' }); // 'success' or 'error'
  const [formData, setFormData] = useState({
    identifier: '',
    username: '',
    email: '',
    firstName: '',
    lastName: '',
    password: ''
  });
  
  const navigate = useNavigate();

  const handleToggle = () => {
    setIsLogin(!isLogin);
    setMessage({ text: '', type: '' }); // Clear messages when swapping
  };

  const { login} = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMessage({ text: '', type: '' });

    try {
      if (isLogin) {
        const response = await api.post('/users/login', {
          identifier: formData.identifier,
          password: formData.password
        });
        login(response.data.token);
        navigate('/dashboard');
      } else {
        const response = await api.post('/users/signup', {
          username: formData.username,
          email: formData.email,
          first_name: formData.firstName,
          last_name: formData.lastName,
          hashed_password: formData.password
        });
        sessionStorage.setItem('token', response.data.token);
        setMessage({ 
          text: 'Account created! Please wait for Admin activation.', 
          type: 'success' 
        });
        setIsLogin(true);
      }
    } catch (error) {
      setMessage({ 
        text: error.response?.data?.detail || 'An error occurred. Please try again.', 
        type: 'error' 
      });
    }
  };

  return (
    <div className="auth-container">
      <h2>{isLogin ? 'Login' : 'Sign Up'}</h2>
      {message.text && (
        <div className={`message-banner ${message.type}`}>
          {message.text}
        </div>
      )}

      <form onSubmit={handleSubmit}>
        {isLogin ? (
          <input 
            type="text" 
            placeholder="Username or Email" 
            required
            onChange={(e) => setFormData({...formData, identifier: e.target.value})} 
          />
        ) : (
          <>
            <input 
              type="text" 
              placeholder="Username" 
              required
              onChange={(e) => setFormData({...formData, username: e.target.value})} 
            />
            <input 
              type="email" 
              placeholder="Email" 
              required
              onChange={(e) => setFormData({...formData, email: e.target.value})} 
            />
            <input 
              type="text" 
              placeholder="First Name" 
              required
              onChange={(e) => setFormData({...formData, firstName: e.target.value})} 
            />
            <input 
              type="text" 
              placeholder="Last Name" 
              required
              onChange={(e) => setFormData({...formData, lastName: e.target.value})} 
            />
          </>
        )}
        
        <input 
          type="password" 
          placeholder="Password" 
          required
          onChange={(e) => setFormData({...formData, password: e.target.value})} 
        />
        
        <button type="submit">{isLogin ? 'Login' : 'Create Account'}</button>
      </form>

      <button className="toggle-link" onClick={handleToggle}>
        {isLogin ? 'Need an account? Sign Up' : 'Back to Login'}
      </button>
    </div>
  );
};

export default Auth;