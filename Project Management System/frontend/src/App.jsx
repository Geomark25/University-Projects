import React from 'react';
import './styles/App.css';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';

//Component Imports
import ProtectedRoute from './components/ProtectedRoute';
import PublicRoute from './components/PublicRoute';
import Layout from './components/Layout';

//Page Imports
import Teams from './pages/Teams';
import Auth from './pages/Auth';
import Dashboard from './pages/Dashboard';
import User from './pages/User';
import AdminPanel from './pages/AdminPanel'
import AdminRoute from './components/AdminRoute';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/auth" element={
            <PublicRoute>
              <Auth />
            </PublicRoute>} />

          <Route path="/dashboard" element={
            <ProtectedRoute>
              <Layout>
                <Dashboard />
              </Layout>
            </ProtectedRoute>} />

          <Route path="/teams" element={
            <ProtectedRoute>
              <Layout>
                <Teams />
              </Layout>
            </ProtectedRoute>} />

          <Route path="/account" element={
            <ProtectedRoute>
              <Layout>
                <User />
              </Layout>
            </ProtectedRoute>} />

          <Route path="/admin" element={
            <ProtectedRoute>
              <AdminRoute>
                <Layout>
                  <AdminPanel />
                </Layout>
              </AdminRoute>
            </ProtectedRoute>
          } />

          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;