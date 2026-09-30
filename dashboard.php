<?php
require_once dirname(__FILE__).'/services/natcon/bootstrap.php';
use function Natcon\{config,database,query};
$c = config();
$db = database($c);

session_name('natcon_staff');
session_set_cookie_params(['httponly'=>true,'secure'=>!empty($_SERVER['HTTPS'])&&$_SERVER['HTTPS']!=='off','samesite'=>'Strict','path'=>'/']);
session_start();

$user = $_SESSION['user'] ?? null;
if (!$user || !in_array($user['role'], ['super_admin', 'admin', 'finance', 'organizer'])) {
    header('Location: index.php');
    exit;
}

// Fetch analytics from new schema
$total_revenue = (int)query($db, "SELECT SUM(amount_kobo) FROM natcon_orders WHERE status='paid'")->fetchColumn();
$total_delegates = (int)query($db, "SELECT COUNT(*) FROM natcon_delegates")->fetchColumn();
$total_pending = (int)query($db, "SELECT COUNT(*) FROM natcon_orders WHERE status='awaiting_review'")->fetchColumn();
$total_checked_in = (int)query($db, "SELECT COUNT(*) FROM natcon_delegates WHERE status='arrived'")->fetchColumn();
$total_events = (int)query($db, "SELECT COUNT(*) FROM natcon_events")->fetchColumn();

// Recent Orders
$recent_orders = query($db, "SELECT reference, payer_name, amount_kobo, payment_method, status FROM natcon_orders ORDER BY created_at DESC LIMIT 6")->fetchAll(PDO::FETCH_ASSOC);

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NATCON Admin Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --primary: #0b1434; --primary-light: #1a2a5e; --accent: #00D261; --bg: #f5f7f9; --text: #333; --card: #fff; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); margin: 0; padding: 0; color: var(--text); }
        .sidebar { width: 250px; background: var(--primary); color: #fff; position: fixed; top: 0; bottom: 0; padding: 20px 0; }
        .sidebar .brand { padding: 0 20px 20px; font-size: 24px; font-weight: 800; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 20px; }
        .sidebar .brand span { color: var(--accent); }
        .sidebar a { display: block; padding: 12px 20px; color: rgba(255,255,255,0.8); text-decoration: none; font-weight: 500; transition: 0.2s; }
        .sidebar a:hover, .sidebar a.active { background: var(--primary-light); color: #fff; border-left: 4px solid var(--accent); }
        .sidebar a i { width: 24px; }
        .main { margin-left: 250px; padding: 30px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header h1 { margin: 0; font-size: 28px; font-weight: 700; color: var(--primary); }
        .user-menu { display: flex; align-items: center; gap: 15px; font-weight: 600; }
        .user-avatar { width: 40px; height: 40px; background: var(--accent); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; }
        
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: var(--card); border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); display: flex; align-items: center; justify-content: space-between; transition: transform 0.2s; border: 1px solid rgba(0,0,0,0.05); }
        .card:hover { transform: translateY(-5px); box-shadow: 0 8px 15px rgba(0,0,0,0.05); }
        .card-info h3 { margin: 0 0 5px; font-size: 14px; color: #666; text-transform: uppercase; letter-spacing: 0.5px; }
        .card-info p { margin: 0; font-size: 28px; font-weight: 800; color: var(--primary); }
        .card-icon { width: 60px; height: 60px; border-radius: 12px; background: rgba(11, 20, 52, 0.05); color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 24px; }
        .card.accent .card-icon { background: rgba(0, 210, 97, 0.1); color: var(--accent); }
        
        .dashboard-layout { display: grid; grid-template-columns: 2fr 1fr; gap: 30px; }
        .panel { background: var(--card); border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); border: 1px solid rgba(0,0,0,0.05); }
        .panel h2 { margin: 0 0 20px; font-size: 18px; color: var(--primary); font-weight: 700; border-bottom: 2px solid var(--bg); padding-bottom: 10px; }
        
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid var(--bg); }
        th { font-size: 13px; color: #666; font-weight: 600; text-transform: uppercase; }
        td { font-size: 14px; font-weight: 500; }
        .badge { padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .badge.paid { background: rgba(0, 210, 97, 0.1); color: var(--accent); }
        .badge.awaiting_review { background: rgba(255, 171, 0, 0.1); color: #ffab00; }
        .badge.cancelled { background: rgba(255, 71, 71, 0.1); color: #ff4747; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="brand">NATCON<span>26</span></div>
        <a href="dashboard.php" class="active"><i class="fas fa-home"></i> Dashboard</a>
        <a href="operations/index.php"><i class="fas fa-tasks"></i> Admin Operations</a>
        <a href="conference/index.php"><i class="fas fa-globe"></i> View Website</a>
        <a href="logout.php"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
    
    <div class="main">
        <div class="header">
            <h1>Overview Analytics</h1>
            <div class="user-menu">
                <span><?php echo htmlspecialchars($user['name']); ?></span>
                <div class="user-avatar"><i class="fas fa-user"></i></div>
            </div>
        </div>
        
        <div class="grid">
            <div class="card accent">
                <div class="card-info">
                    <h3>Total Revenue</h3>
                    <p>₦<?php echo number_format($total_revenue / 100, 2); ?></p>
                </div>
                <div class="card-icon"><i class="fas fa-wallet"></i></div>
            </div>
            <div class="card">
                <div class="card-info">
                    <h3>Total Delegates</h3>
                    <p><?php echo number_format($total_delegates); ?></p>
                </div>
                <div class="card-icon"><i class="fas fa-users"></i></div>
            </div>
            <div class="card">
                <div class="card-info">
                    <h3>Pending Reviews</h3>
                    <p><?php echo number_format($total_pending); ?></p>
                </div>
                <div class="card-icon"><i class="fas fa-clock"></i></div>
            </div>
            <div class="card accent">
                <div class="card-info">
                    <h3>Checked-In</h3>
                    <p><?php echo number_format($total_checked_in); ?></p>
                </div>
                <div class="card-icon"><i class="fas fa-qrcode"></i></div>
            </div>
        </div>
        
        <div class="dashboard-layout">
            <div class="panel">
                <h2>Registration Trends</h2>
                <canvas id="revenueChart" height="120"></canvas>
            </div>
            
            <div class="panel">
                <h2>Recent Orders</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Amount</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($recent_orders as $order): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($order['payer_name']); ?></td>
                            <td>₦<?php echo number_format($order['amount_kobo']/100, 2); ?></td>
                            <td><span class="badge <?php echo $order['status']; ?>"><?php echo ucfirst(str_replace('_', ' ', $order['status'])); ?></span></td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if(empty($recent_orders)): ?>
                        <tr><td colspan="3" style="text-align:center;color:#999;">No orders yet.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script>
        const ctx = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Registrations',
                    data: [0, 0, 0, 0, 0, 0, <?php echo $total_delegates; ?>],
                    borderColor: '#0b1434',
                    backgroundColor: 'rgba(11, 20, 52, 0.1)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { display: false } },
                scales: { 
                    y: { beginAtZero: true, grid: { borderDash: [5, 5] }, ticks: { stepSize: 1 } },
                    x: { grid: { display: false } }
                }
            }
        });
    </script>
</body>
</html>
