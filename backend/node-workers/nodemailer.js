require('dotenv').config();
const mysql = require('mysql2/promise');
const nodemailer = require('nodemailer');

// Gmail transporter using your app password
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'cos30049group6@gmail.com',
    pass: process.env.GMAIL_APP_PASSWORD, 
  },
});

// Create MySQL pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

// Delay helper
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Main logic: Fetch unsent notifications and send them
let isRunning = false;

async function sendUnsentNotifications() {
  if (isRunning) return; // Prevent overlap, stop if already running
  isRunning = true;

  try { // Get all notifications is_sent = FALSE
    const [notifications] = await pool.query(` 
      SELECT 
        n.notification_id,
        n.message_content,
        n.customer_id,
        n.staff_id,
        c.email AS customer_email,
        s.email AS staff_email
      FROM Notifications n
      LEFT JOIN Customers c ON n.customer_id = c.customer_id
      LEFT JOIN Staff s ON n.staff_id = s.staff_id
      WHERE n.is_sent = FALSE
    `);

    // If no new notification
    if (notifications.length === 0) {
      console.log('⏳ No new notifications to send.');
      isRunning = false;
      return;
    }

    // Loop through each unsent notification
    for (const noti of notifications) {
      try {
        let recipientEmail = null;

        // Determine the recipient email (customer or staff)
        if (noti.customer_id && noti.customer_email) {
          recipientEmail = noti.customer_email;
        } else if (noti.staff_id && noti.staff_email) {
          recipientEmail = noti.staff_email;
        }

        // If no email found
        if (!recipientEmail) {
          console.warn(`No valid email found for notification_id ${noti.notification_id}`);
          continue;
        }

        // Email content
        const mailOptions = {
          from: 'cos30049group6@gmail.com',
          to: recipientEmail,
          subject: 'Thông báo từ hệ thống FPT Long Châu',
          text: `${noti.message_content}\n\nNotification ID: ${noti.notification_id}`,
        };

        const info = await transporter.sendMail(mailOptions);  // Send the email

        // Set is_sent = TRUE
        await pool.query(`
          UPDATE Notifications
          SET is_sent = TRUE
          WHERE notification_id = ?
        `, [noti.notification_id]);

        console.log(`✅ Email sent to ${recipientEmail} for notification_id ${noti.notification_id}`);
      } catch (sendErr) {
        console.error(`❌ Error sending notification_id ${noti.notification_id}:`, sendErr.message);
      }

      await sleep(1000); // 1s delay to avoid spamming
    }
  } catch (err) {
    console.error('Error querying notifications:', err);
  } finally {
    isRunning = false;
  }
}

// Check db every 5 secs
setInterval(sendUnsentNotifications, 5000);
