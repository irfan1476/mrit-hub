const API_BASE = '/api/v1';
let currentUser = null;

// Initialize dashboard
document.addEventListener('DOMContentLoaded', function() {
    checkUserRole();
    loadUserInfo();
    setCurrentDate();
    loadTodaySchedule();
    loadLeaveOverview();
    loadApprovals();
});

async function checkUserRole() {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        window.location.href = '/index.html';
        return;
    }
}

function setCurrentDate() {
    const now = new Date();
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    document.getElementById('currentDate').textContent = now.toLocaleDateString('en-US', options);
    document.getElementById('scheduleDate').value = now.toISOString().split('T')[0];
}

async function loadUserInfo() {
    try {
        const token = localStorage.getItem('accessToken');
        const response = await fetch(`${API_BASE}/dashboard/protected/faculty-info`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        if (response.ok) {
            currentUser = await response.json();
            
            const greeting = getGreeting();
            document.getElementById('facultyGreeting').textContent = `${greeting}, ${currentUser.name}`;
            document.getElementById('facultyDetails').textContent = 
                `${currentUser.department} • ${currentUser.designation} • ${currentUser.employeeCode}`;
            
            const initials = currentUser.name.split(' ').map(n => n[0]).join('');
            document.getElementById('profilePic').textContent = initials;
        }
    } catch (error) {
        console.error('Error loading user info:', error);
    }
}

function getGreeting() {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
}

async function loadTodaySchedule() {
    try {
        const date = document.getElementById('scheduleDate').value;
        const token = localStorage.getItem('accessToken');
        const response = await fetch(`${API_BASE}/dashboard/protected/today-schedule?date=${date}`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        
        if (response.ok) {
            const schedule = await response.json();
            updateTimetableDisplay(schedule);
        } else {
            document.getElementById('timetable').innerHTML += '<div style="grid-column: 1/-1; text-align: center; padding: 2rem; color: var(--text-secondary);">No classes scheduled</div>';
        }
    } catch (error) {
        console.error('Error loading schedule:', error);
    }
}

function updateTimetableDisplay(schedule) {
    const timetable = document.getElementById('timetable');
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentTime = currentHour * 60 + currentMinute;
    
    timetable.innerHTML = `
        <div class="time-header">Time</div>
        <div class="time-header">9:15 AM</div>
        <div class="time-header">10:15 AM</div>
        <div class="time-header">11:30 AM</div>
        <div class="time-header">12:30 PM</div>
        <div class="time-header">2:30 PM</div>
        <div class="time-header">3:30 PM</div>
    `;
    
    if (schedule.length === 0) {
        timetable.innerHTML += '<div class="period-slot" style="grid-column: 1/-1; text-align: center; color: var(--text-secondary);">No classes scheduled for today</div>';
        return;
    }
    
    timetable.innerHTML += '<div class="time-header">Schedule</div>';
    
    schedule.forEach(slot => {
        // Parse slot time to determine status
        const [startHour, startMin] = slot.time.split(':').map(Number);
        const slotStartTime = startHour * 60 + startMin;
        const slotEndTime = slotStartTime + 60; // Assume 1 hour duration
        
        let status = '';
        if (currentTime >= slotStartTime && currentTime < slotEndTime) {
            status = 'current';
        } else if (currentTime < slotStartTime && currentTime >= slotStartTime - 60) {
            status = 'upcoming';
        } else if (currentTime >= slotEndTime) {
            status = 'completed';
        }
        
        const slotDiv = document.createElement('div');
        slotDiv.className = `period-slot ${status}`;
        slotDiv.setAttribute('data-time', `${slot.time} - ${slot.endTime || ''}`);
        slotDiv.onclick = () => navigateToAttendance(slot);
        slotDiv.innerHTML = `
            <div class="subject-info">${slot.subject || slot.course}</div>
            <div class="class-info">
                <i class="fas fa-book"></i> ${slot.course || slot.subject}
            </div>
            ${slot.room ? `<div class="class-info"><i class="fas fa-door-open"></i> ${slot.room}</div>` : ''}
            ${slot.classType ? `<div class="class-info"><i class="fas fa-chalkboard-teacher"></i> ${slot.classType}</div>` : ''}
        `;
        timetable.appendChild(slotDiv);
    });
}

async function loadLeaveOverview() {
    try {
        const token = localStorage.getItem('accessToken');
        const response = await fetch(`${API_BASE}/dashboard/leave-overview`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        
        if (response.ok) {
            const leaveData = await response.json();
            
            document.getElementById('pendingLeaves').textContent = leaveData.stats.pending;
            document.getElementById('approvedLeaves').textContent = leaveData.stats.approved;
            document.getElementById('rejectedLeaves').textContent = leaveData.stats.rejected;
            
            updateLeaveBalanceDisplay(leaveData.balances);
            updateRecentLeave(leaveData.recent);
        }
    } catch (error) {
        console.error('Error loading leave overview:', error);
    }
}

function updateLeaveBalanceDisplay(balances) {
    const balanceContainer = document.querySelector('.leave-balance');
    if (balances && balances.length > 0) {
        const balanceHTML = '<h4 style="margin-bottom: 1rem;">Balance:</h4>' + balances.slice(0, 3).map(balance => {
            const percentage = (balance.remaining / balance.total) * 100;
            return `<div class="balance-item">
                <div>
                    <span>${balance.name} (${balance.type})</span>
                    <div class="balance-bar">
                        <div class="balance-fill" style="width: ${percentage}%"></div>
                    </div>
                </div>
                <span><strong>${balance.remaining}/${balance.total}</strong></span>
            </div>`;
        }).join('');
        balanceContainer.innerHTML = balanceHTML;
    }
}

function updateRecentLeave(recent) {
    const recentContainer = document.querySelector('.recent-leave');
    if (recent) {
        recentContainer.innerHTML = `
            <h4>Last Update:</h4>
            <p><i class="fas fa-info-circle"></i> ${recent.type} | <strong>${recent.status}</strong> | ${recent.date}</p>
        `;
    }
}

async function loadApprovals() {
    try {
        const token = localStorage.getItem('accessToken');
        const response = await fetch(`${API_BASE}/dashboard/approvals`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        
        if (response.ok) {
            const approvals = await response.json();
            updateApprovalsDisplay(approvals);
        }
    } catch (error) {
        console.error('Error loading approvals:', error);
    }
}

function updateApprovalsDisplay(approvals) {
    const subContainer = document.getElementById('substituteApprovals');
    const hodContainer = document.getElementById('hodApprovals');
    
    if (approvals.substitute && approvals.substitute.length > 0) {
        subContainer.innerHTML = approvals.substitute.map(approval => `
            <div class="approval-item">
                <strong><i class="fas fa-user-clock"></i> Substitute Request</strong>
                <p>${approval.facultyName} - ${approval.leaveType}</p>
                <p><i class="fas fa-calendar"></i> ${approval.dates}</p>
                <div class="approval-actions">
                    <button class="approve-btn"><i class="fas fa-check"></i> Accept</button>
                    <button class="reject-btn"><i class="fas fa-times"></i> Reject</button>
                </div>
            </div>
        `).join('');
    } else {
        subContainer.innerHTML = '<p style="color: var(--text-secondary); text-align: center;">No pending approvals</p>';
    }
    
    if (approvals.hod && approvals.hod.length > 0) {
        hodContainer.innerHTML = approvals.hod.map(approval => `
            <div class="approval-item hod">
                <strong><i class="fas fa-user-tie"></i> HOD Approval</strong>
                <p>${approval.facultyName} - ${approval.leaveType}</p>
                <p><i class="fas fa-calendar"></i> ${approval.dates} (${approval.days} days)</p>
                <div class="approval-actions">
                    <button class="approve-btn"><i class="fas fa-check"></i> Approve</button>
                    <button class="reject-btn"><i class="fas fa-times"></i> Reject</button>
                </div>
            </div>
        `).join('');
    }
}

function loadSchedule() {
    loadTodaySchedule();
}

function logout() {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        window.location.href = 'index.html';
    }
}

function navigateToAttendance(slot) {
    const params = new URLSearchParams({
        date: document.getElementById('scheduleDate').value,
        department: slot.departmentCode,
        semester: slot.semester,
        section: slot.sectionName,
        subject: slot.courseCode,
        timeSlot: slot.timeSlot,
        autoCreate: 'true'
    });
    
    window.location.href = `attendance.html?${params.toString()}`;
}
