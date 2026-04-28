const colors = {
  primary: '#2563eb',
  primaryHover: '#1d4ed8',
  success: '#10b981',
  danger: '#ef4444',
  surface: '#ffffff',
  background: '#f8fafc',
  textMain: '#1e293b',
  textMuted: '#64748b',
  border: '#e2e8f0'
};

export const styles = {
  container: { padding: '40px 20px', maxWidth: '1200px', margin: '0 auto', fontFamily: '"Inter", sans-serif', color: colors.textMain },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' },
  
  card: { 
    background: colors.surface, 
    borderRadius: '16px', 
    border: `1px solid ${colors.border}`, 
    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03)',
    overflow: 'hidden' 
  },
  toolbar: { padding: '24px', borderBottom: `1px solid ${colors.border}`, display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#ffffff' },
  
  tabGroup: { display: 'flex', gap: '8px', background: '#f1f5f9', padding: '6px', borderRadius: '12px' },
  tabBtn: { padding: '8px 20px', border: 'none', background: 'transparent', cursor: 'pointer', borderRadius: '8px', fontSize: '14px', fontWeight: '600', color: colors.textMuted, transition: 'all 0.2s' },
  activeTabBtn: { padding: '8px 20px', border: 'none', background: colors.surface, cursor: 'pointer', borderRadius: '8px', fontSize: '14px', fontWeight: '600', color: colors.primary, boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' },
  
  table: { width: '100%', borderCollapse: 'separate', borderSpacing: 0 },
  th: { background: '#f8fafc', textAlign: 'left', borderBottom: `1px solid ${colors.border}`, color: colors.textMuted, fontSize: '12px', textTransform: 'uppercase', padding: '16px 24px', letterSpacing: '0.05em', fontWeight: '700' },
  tr: { transition: 'background 0.2s' },
  td: { padding: '20px 24px', fontSize: '14px', borderBottom: `1px solid ${colors.border}` },
  
  overlay: { position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(15, 23, 42, 0.6)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000, backdropFilter: 'blur(8px)' },
  modal: { background: colors.surface, padding: '40px', borderRadius: '24px', width: '440px', boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)', border: '1px solid rgba(255,255,255,0.2)' },
  
  input: { width: '100%', padding: '12px 16px', borderRadius: '10px', border: `1px solid ${colors.border}`, boxSizing: 'border-box', marginTop: '8px', fontSize: '14px', outline: 'none', transition: 'border-color 0.2s' },
  label: { fontSize: '13px', fontWeight: '600', color: colors.textMain },
  
  btnSave: { flex: 2, padding: '14px', background: colors.primary, color: '#fff', border: `1px solid ${colors.primaryHover}`, borderRadius: '12px', cursor: 'pointer', fontWeight: '600', fontSize: '14px' },
  btnCancel: { flex: 1, padding: '14px', background: '#ffffff', color: colors.textMain, border: `1px solid ${colors.border}`, borderRadius: '12px', cursor: 'pointer', fontWeight: '600', fontSize: '14px' },
  
  actionBtnFrame: { padding: '6px 14px', background: '#ffffff', border: `1px solid ${colors.border}`, borderRadius: '8px', color: '#3182ce', fontWeight: '700', cursor: 'pointer', fontSize: '13px', whiteSpace: 'nowrap' },
  
  deleteBtnFrame: { 
    width: '32px',
    height: '32px',
    padding: '0', 
    background: '#fef2f2', 
    border: '1px solid #fee2e2', 
    borderRadius: '8px', 
    color: '#e53e3e', 
    cursor: 'pointer', 
    display: 'flex', 
    alignItems: 'center', 
    justifyContent: 'center',
    flexShrink: 0 
  },

  memberList: { marginTop: '20px', maxHeight: '200px', overflowY: 'auto', borderRadius: '12px', border: '1px solid #e2e8f0', padding: '8px' },
  memberItem: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 12px', borderRadius: '8px', marginBottom: '4px', background: '#f8fafc' },
  addSection: { display: 'flex', gap: '8px', marginTop: '12px', alignItems: 'center' },
  textarea: { width: '100%', padding: '12px 16px', borderRadius: '10px', border: '1px solid #e2e8f0', boxSizing: 'border-box', marginTop: '8px', fontSize: '14px', outline: 'none', minHeight: '80px', fontFamily: 'inherit', resize: 'vertical' },
  truncate: { maxWidth: '250px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', color: '#64748b', fontSize: '13px' }
};