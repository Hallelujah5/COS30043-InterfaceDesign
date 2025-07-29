# Node.js Email Notification Service

This worker script sends automated email notifications for the Pharmacy System using Gmail and MySQL.

## 📦 Setup

### 1. Create the `.env` file

In the `backend/node-workers` folder, create a file named `.env` with the following content:

```
DB_HOST=localhost
DB_USER=...
DB_PASS=...
DB_NAME=pharmacy_db

GMAIL_APP_PASSWORD=your_app_password
```

- Replace your database details, and `your_app_password` with your actual Gmail App Password (see below).

### 2. How to Get Your Gmail App Password

1. Go to [Google Account Security](https://myaccount.google.com/security).
2. Enable **2-Step Verification** for your Gmail account if you haven't already.
3. After enabling, go to **App Passwords**.
4. Select **Mail** as the app and **Other** (or your device) as the device.
5. Click **Generate**.
6. Copy the generated password and paste it as `GMAIL_APP_PASSWORD` in your `.env` file.

### 3. Install Dependencies

Open Command Prompt and run:
```cmd
cd \backend\node-workers
npm install
```

### 4. Run the Worker

```cmd
node nodemailer.js
```

---

**Your `.env` file should look something like this:**
```
DB_HOST=localhost
DB_USER=root
DB_PASS=root
DB_NAME=pharmacy_db

GMAIL_APP_PASSWORD=xxxx xxxx xxxx xxxx
```
