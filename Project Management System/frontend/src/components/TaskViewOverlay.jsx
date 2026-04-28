import React, { useState, useEffect, useRef } from 'react';
import api from '../api/axiosInstance';
import { styles } from '../components/adminStyles';
import { Paperclip, Download, FileText, Loader2, X, Trash2, Send, MessageSquare } from 'lucide-react';

const TaskViewOverlay = ({ task, users, teams, isLeader, onUpdate, onClose }) => {
  const [comments, setComments] = useState([]);
  const [assignees, setAssignees] = useState([]);
  const [attachments, setAttachments] = useState([]);
  
  // Loading States
  const [uploading, setUploading] = useState(false);
  const [downloadingId, setDownloadingId] = useState(null);
  const [deletingId, setDeletingId] = useState(null);
  const [sendingComment, setSendingComment] = useState(false);
  
  // Inputs
  const [commentText, setCommentText] = useState("");
  const commentsEndRef = useRef(null);

  const fetchTaskDetails = async () => {
    try {
      const [commRes, assignRes, attRes] = await Promise.all([
        api.get(`/tasks/${task.id}/comments`),
        api.get(`/tasks/${task.id}/assignees`),
        api.get(`/tasks/${task.id}/attachments`)
      ]);
      setComments(commRes.data || []);
      setAssignees(assignRes.data || []);
      setAttachments(attRes.data || []);
    } catch (err) {
      console.error("Error fetching task details:", err);
    }
  };

  useEffect(() => {
    if (task) fetchTaskDetails();
  }, [task]);

  useEffect(() => {
    commentsEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [comments]);


  const handlePostComment = async () => {
    if (!commentText.trim()) return;
    setSendingComment(true);
    try {
      await api.post(`/tasks/${task.id}/comments`, { content: commentText });
      setCommentText("");
      const res = await api.get(`/tasks/${task.id}/comments`);
      setComments(res.data || []);
    } catch (err) {
      console.error("Comment failed:", err);
    } finally {
      setSendingComment(false);
    }
  };

  const handleFileUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);

    setUploading(true);
    try {
      await api.post(`/tasks/${task.id}/attachments`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      fetchTaskDetails();
    } catch (err) {
      alert("Error uploading file.");
    } finally {
      setUploading(false);
    }
  };

  const handleDownload = async (attachment) => {
    setDownloadingId(attachment.id);
    try {
      const response = await api.get(`/tasks/attachments/${attachment.id}/download`, { responseType: 'blob' });
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', attachment.filename);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      alert("Failed to download file.");
    } finally {
      setDownloadingId(null);
    }
  };

  const handleDeleteAttachment = async (id) => {
    if (!window.confirm("Delete this file?")) return;
    setDeletingId(id);
    try {
      await api.delete(`/tasks/attachments/${id}`);
      setAttachments(prev => prev.filter(a => a.id !== id));
    } catch (err) {
      alert("Failed to delete.");
    } finally {
      setDeletingId(null);
    }
  };

  const teamName = teams?.find(t => t.id === task.team_id)?.name || "N/A";
  const isLocked = task.state === 'done';

  return (
    <div style={styles.overlay}>
      <div style={layoutStyles.modal}>
        
        {/* --- HEADER --- */}
        <div style={layoutStyles.header}>
          <h2 style={{ margin: 0, display: 'flex', alignItems: 'center', gap: '10px' }}>
            {task.title}
            <span style={{ fontSize: '12px', background: '#f1f5f9', padding: '4px 8px', borderRadius: '4px', color: '#64748b' }}>#{task.id}</span>
          </h2>
          <button onClick={onClose} style={layoutStyles.closeIcon}><X /></button>
        </div>

        {/* --- BODY GRID --- */}
        <div style={layoutStyles.bodyGrid}>
          
          {/* LEFT COLUMN: DETAILS & ATTACHMENTS */}
          <div style={layoutStyles.leftColumn}>
            
            {/* Metadata */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '20px' }}>
              <div><label style={styles.label}>Team</label><div style={infoStyle}>{teamName}</div></div>
              
              {/* Status Selector */}
              {onUpdate && (
                <div>
                  <label style={styles.label}>Status</label>
                  <select 
                    value={task.state} 
                    onChange={(e) => onUpdate(task.id, e.target.value)} 
                    disabled={isLocked}
                    style={{ ...styles.input, padding: '4px', height: '30px', fontSize: '12px' }}
                  >
                    <option value="to_do">TO DO</option>
                    <option value="in_progress">IN PROGRESS</option>
                    <option value="done">DONE</option>
                  </select>
                </div>
              )}
            </div>

            {/* Assignees */}
            <div style={{ marginBottom: '25px' }}>
              <label style={styles.label}>Assignees</label>
              <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginTop: '6px' }}>
                {assignees.length > 0 ? assignees.map(a => (
                  <span key={a.user_id} style={badgeStyle}>
                    {users.find(u => String(u.user_id) === String(a.user_id))?.username || `User ${a.user_id}`}
                  </span>
                )) : <span style={{ fontSize: '12px', color: '#94a3b8' }}>No assignees</span>}
              </div>
            </div>

            {/* Attachments Section */}
            <div style={{ borderTop: '1px solid #e2e8f0', paddingTop: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                <label style={styles.label}>Attachments</label>
                <label style={uploadTriggerStyle}>
                  {uploading ? <Loader2 size={12} className="animate-spin" /> : <Paperclip size={12} />}
                  {uploading ? ' Uploading...' : ' Upload'}
                  <input type="file" hidden onChange={handleFileUpload} disabled={uploading} />
                </label>
              </div>

              <div style={attachmentListStyle}>
                {attachments.length === 0 && !uploading && (
                  <div style={{ textAlign: 'center', color: '#cbd5e1', fontSize: '12px', padding: '10px' }}>No files yet.</div>
                )}
                
                {attachments.map(file => (
                  <div key={file.id} style={attachmentItemStyle}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', overflow: 'hidden' }}>
                      <FileText size={14} color="#64748b" />
                      <span style={{ fontSize: '12px', fontWeight: '600', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: '180px' }}>
                        {file.filename}
                      </span>
                    </div>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <button onClick={() => handleDownload(file)} style={iconBtnStyle} title="Download">
                        {downloadingId === file.id ? <Loader2 size={14} className="animate-spin" /> : <Download size={14} />}
                      </button>
                      {isLeader && (
                        <button onClick={() => handleDeleteAttachment(file.id)} style={{ ...iconBtnStyle, color: '#ef4444' }} title="Delete">
                          {deletingId === file.id ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <button onClick={onClose} style={{ ...styles.btnCancel, width: '100%', marginTop: 'auto' }}>Close Details</button>
          </div>

          {/* RIGHT COLUMN: DISCUSSION */}
          <div style={layoutStyles.rightColumn}>
            <div style={{ padding: '20px', borderBottom: '1px solid #e2e8f0', background: '#f8fafc' }}>
              <h3 style={{ margin: 0, fontSize: '14px', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <MessageSquare size={16} /> Discussion
              </h3>
            </div>

            {/* Chat History */}
            <div style={layoutStyles.chatHistory}>
              {comments.length === 0 ? (
                <div style={{ textAlign: 'center', color: '#94a3b8', fontSize: '13px', marginTop: '40px' }}>
                  No comments yet.<br/>Start the conversation!
                </div>
              ) : (
                comments.map(c => {
                  const author = users.find(u => String(u.user_id) === String(c.user_id));
                  return (
                    <div key={c.id} style={chatBubbleContainer}>
                      <div style={chatHeaderStyle}>
                        <span style={{ fontWeight: '800', color: '#334155' }}>{author?.username || `User ${c.user_id}`}</span>
                        <span style={{ fontSize: '10px', color: '#94a3b8' }}>{new Date(c.created_at).toLocaleString()}</span>
                      </div>
                      <div style={chatBubbleStyle}>{c.content}</div>
                    </div>
                  );
                })
              )}
              <div ref={commentsEndRef} />
            </div>

            {/* Input Area */}
            <div style={layoutStyles.chatInputArea}>
              <textarea
                value={commentText}
                onChange={(e) => setCommentText(e.target.value)}
                placeholder="Type your message..."
                style={chatInputStyle}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handlePostComment();
                  }
                }}
              />
              <button 
                onClick={handlePostComment} 
                disabled={sendingComment || !commentText.trim()}
                style={sendBtnStyle}
              >
                {sendingComment ? <Loader2 size={18} className="animate-spin" /> : <Send size={18} />}
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
};

// --- STYLES ---

const layoutStyles = {
  modal: { 
    background: '#fff', 
    width: '900px', // Wider modal for side-by-side
    maxWidth: '95vw',
    height: '80vh', 
    borderRadius: '16px', 
    display: 'flex', 
    flexDirection: 'column', 
    overflow: 'hidden',
    boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)'
  },
  header: {
    padding: '20px',
    borderBottom: '1px solid #e2e8f0',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    background: '#fff',
    zIndex: 10
  },
  bodyGrid: {
    display: 'grid',
    gridTemplateColumns: '1fr 350px', // Split layout
    height: '100%',
    overflow: 'hidden'
  },
  leftColumn: {
    padding: '25px',
    overflowY: 'auto',
    display: 'flex',
    flexDirection: 'column',
    gap: '10px'
  },
  rightColumn: {
    borderLeft: '1px solid #e2e8f0',
    background: '#f8fafc',
    display: 'flex',
    flexDirection: 'column',
    height: '100%'
  },
  chatHistory: {
    flex: 1,
    padding: '20px',
    overflowY: 'auto',
    display: 'flex',
    flexDirection: 'column',
    gap: '15px'
  },
  chatInputArea: {
    padding: '15px',
    borderTop: '1px solid #e2e8f0',
    background: '#fff',
    display: 'flex',
    gap: '10px',
    alignItems: 'flex-end'
  },
  closeIcon: { background: 'none', border: 'none', cursor: 'pointer', color: '#64748b' }
};

const infoStyle = { fontWeight: '700', fontSize: '14px', color: '#0f172a', marginTop: '4px' };
const badgeStyle = { background: '#f1f5f9', padding: '4px 8px', borderRadius: '4px', fontSize: '11px', fontWeight: '700', color: '#475569', border: '1px solid #e2e8f0' };

const attachmentListStyle = { marginTop: '10px', display: 'flex', flexDirection: 'column', gap: '8px' };
const attachmentItemStyle = { display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#fff', padding: '8px 12px', borderRadius: '6px', border: '1px solid #e2e8f0' };
const uploadTriggerStyle = { display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', fontWeight: '800', color: '#0f172a', cursor: 'pointer', background: '#f1f5f9', padding: '6px 10px', borderRadius: '6px' };
const iconBtnStyle = { background: 'none', border: 'none', cursor: 'pointer', color: '#2563eb', padding: '4px', display: 'flex', alignItems: 'center' };

const chatBubbleContainer = { display: 'flex', flexDirection: 'column', gap: '4px' };
const chatHeaderStyle = { display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '11px', marginBottom: '2px' };
const chatBubbleStyle = { background: '#fff', padding: '10px', borderRadius: '0 12px 12px 12px', border: '1px solid #e2e8f0', fontSize: '13px', color: '#334155', boxShadow: '0 1px 2px rgba(0,0,0,0.05)', lineHeight: '1.4' };
const chatInputStyle = { flex: 1, padding: '10px', borderRadius: '8px', border: '1px solid #cbd5e1', fontSize: '13px', resize: 'none', height: '40px', outline: 'none', fontFamily: 'inherit' };
const sendBtnStyle = { background: '#0f172a', color: '#fff', border: 'none', borderRadius: '8px', width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' };

export default TaskViewOverlay;