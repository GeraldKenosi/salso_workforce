const express = require("express");
const cors = require("cors");
const https = require("https");
const admin = require("firebase-admin");

// ─── Firebase Admin (from individual env vars or Base64 blob) ───
const hasServiceAccount = process.env.FIREBASE_PROJECT_ID
  && process.env.FIREBASE_CLIENT_EMAIL
  && process.env.FIREBASE_PRIVATE_KEY_BASE64
  && process.env.FIREBASE_PRIVATE_KEY_ID;

if (hasServiceAccount) {
  const creds = {
    type: "service_account",
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: Buffer.from(process.env.FIREBASE_PRIVATE_KEY_BASE64, "base64").toString("utf8"),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID || "",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${encodeURIComponent(process.env.FIREBASE_CLIENT_EMAIL)}`,
  };
  admin.initializeApp({ credential: admin.credential.cert(creds) });
} else if (process.env.GOOGLE_CREDENTIALS_BASE64) {
  const creds = JSON.parse(
    Buffer.from(process.env.GOOGLE_CREDENTIALS_BASE64, "base64").toString()
  );
  admin.initializeApp({ credential: admin.credential.cert(creds) });
} else {
  admin.initializeApp();
}

const db = admin.firestore();
const auth = admin.auth();
const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// ─── Auth middleware (optional, for endpoints that need it) ───
async function requireAdmin(req, res, next) {
  const token = req.headers.authorization?.replace("Bearer ", "");
  if (!token) return res.status(401).json({ error: "Unauthorized" });
  try {
    const decoded = await auth.verifyIdToken(token);
    const userDoc = await db.collection("users").doc(decoded.uid).get();
    const userData = userDoc.data();
    if (!userData || !["admin", "ed"].includes(userData.roleTemplateId)) {
      return res.status(403).json({ error: "Forbidden" });
    }
    req.user = { ...decoded, ...userData };
    next();
  } catch (e) {
    return res.status(401).json({ error: "Invalid token" });
  }
}

// ─── Helper: generate temp password ───
function generateTempPassword() {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789";
  let result = "";
  for (let i = 0; i < 12; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result + "A1!";
}

// ─── Helper: SharePoint config ───
function sharePointConfig() {
  return {
    tenantId: process.env.SHAREPOINT_TENANT_ID || "your-tenant-id",
    clientId: process.env.SHAREPOINT_CLIENT_ID || "your-client-id",
    clientSecret: process.env.SHAREPOINT_CLIENT_SECRET || "your-client-secret",
    siteId: process.env.SHAREPOINT_SITE_ID || "your-site-id",
    driveId: process.env.SHAREPOINT_DRIVE_ID || "your-drive-id",
  };
}

// ─── Helper: get Microsoft Graph token ───
function getGraphToken(config) {
  return new Promise((resolve, reject) => {
    const body = new URLSearchParams({
      client_id: config.clientId,
      client_secret: config.clientSecret,
      scope: "https://graph.microsoft.com/.default",
      grant_type: "client_credentials",
    }).toString();

    const req = https.request({
      hostname: "login.microsoftonline.com",
      path: `/${config.tenantId}/oauth2/v2.0/token`,
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded", "Content-Length": Buffer.byteLength(body) },
    }, (res) => {
      let data = "";
      res.on("data", (chunk) => data += chunk);
      res.on("end", () => {
        try { resolve(JSON.parse(data).access_token); } catch (e) { reject(new Error("Failed to get token")); }
      });
    });
    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

// ─── Helper: upload file to SharePoint via Graph API ───
function uploadToSharePoint(token, config, drivePath, fileBuffer, fileName) {
  return new Promise((resolve, reject) => {
    const url = new URL(`https://graph.microsoft.com/v1.0/sites/${config.siteId}/drives/${config.driveId}/root:${drivePath}/${fileName}:/content`);
    const req = https.request({
      hostname: url.hostname,
      path: url.pathname + url.search,
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/octet-stream",
        "Content-Length": fileBuffer.length,
      },
    }, (res) => {
      let data = "";
      res.on("data", (chunk) => data += chunk);
      res.on("end", () => {
        try { resolve(JSON.parse(data)); } catch (e) { reject(new Error("Upload to SharePoint failed")); }
      });
    });
    req.on("error", reject);
    req.write(fileBuffer);
    req.end();
  });
}

// ════════════════════════════════════════════
//  ENDPOINTS
// ════════════════════════════════════════════

// ─── Health ───
app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", timestamp: Date.now() });
});

// ─── HR Create User ───
app.post("/api/hr-create-user", async (req, res) => {
  try {
    const { fullName, email, roleTemplateId, programmeId, teamId } = req.body;

    if (!fullName || !email || !roleTemplateId) {
      return res.status(400).json({ error: "Missing required fields: fullName, email, roleTemplateId" });
    }

    const tempPassword = generateTempPassword();
    const user = await auth.createUser({
      email: email.trim().toLowerCase(),
      password: tempPassword,
      displayName: fullName.trim(),
      disabled: false,
    });

    await db.collection("users").doc(user.uid).set({
      uid: user.uid,
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      roleTemplateId: roleTemplateId.trim(),
      programmeId: (programmeId || "").trim(),
      teamId: (teamId || "").trim(),
      status: "active",
      authProvisioned: true,
      createdAtMs: Date.now(),
    });

    return res.json({
      uid: user.uid,
      email: user.email,
      message: "User created successfully.",
    });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// ─── File transfer: Firebase Storage → SharePoint ───
app.post("/api/file-transfer-sharepoint", async (req, res) => {
  try {
    const { storagePath, sharePointPath, fileName } = req.body;
    if (!storagePath || !sharePointPath || !fileName) {
      return res.status(400).json({ error: "Missing required fields: storagePath, sharePointPath, fileName" });
    }

    const bucket = admin.storage().bucket();
    const file = bucket.file(storagePath);
    const [exists] = await file.exists();
    if (!exists) return res.status(404).json({ error: "File not found in storage" });

    const [contents] = await file.download();
    const config = sharePointConfig();
    const token = await getGraphToken(config);
    const result = await uploadToSharePoint(token, config, sharePointPath, contents, fileName);

    return res.json({ success: true, sharePointUrl: result?.webUrl || "Uploaded" });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// ─── QR Self-Service HTML ───
app.get("/api/qr-self-service", (req, res) => {
  const registerId = req.query.registerId || "";
  const registerName = req.query.registerName || "Attendance";

  if (!registerId) {
    return res.status(400).send("Missing registerId parameter");
  }

  function escapeHtml(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  }

  const host = `${req.protocol}://${req.hostname}`;
  const apiOrigin = process.env.API_ORIGIN || host;

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sign In - SALSO</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #f5f5f5; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
    .card { background: white; border-radius: 16px; padding: 32px; box-shadow: 0 4px 24px rgba(0,0,0,0.1); width: 90%; max-width: 400px; }
    h1 { font-size: 20px; margin-bottom: 8px; text-align: center; }
    p.sub { color: #666; text-align: center; margin-bottom: 24px; font-size: 14px; }
    input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px; margin-bottom: 12px; }
    button { width: 100%; padding: 14px; background: #D90429; color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; }
    button:hover { background: #b00322; }
    .success { text-align: center; color: #2e7d32; margin-top: 16px; font-weight: 600; display: none; }
    .error { text-align: center; color: #c62828; margin-top: 16px; display: none; }
    .logo { text-align: center; margin-bottom: 16px; }
    .logo svg { width: 48px; height: 48px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">
      <svg viewBox="0 0 40 40" fill="#D90429"><circle cx="20" cy="20" r="18"/></svg>
    </div>
    <h1>Sign In</h1>
    <p class="sub">${escapeHtml(registerName)}</p>
    <input type="text" id="name" placeholder="Full Name" autocomplete="name" required>
    <input type="tel" id="phone" placeholder="Phone (optional)" autocomplete="tel">
    <button onclick="signIn()">Sign In</button>
    <div class="success" id="success">✓ Signed in successfully!</div>
    <div class="error" id="error"></div>
  </div>
  <script>
    async function signIn() {
      const name = document.getElementById("name").value.trim();
      const phone = document.getElementById("phone").value.trim();
      if (!name) { showError("Name is required"); return; }
      try {
        const r = await fetch("${apiOrigin}/api/sign-in", {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({registerId: "${registerId}", name, phone}),
        });
        const data = await r.json();
        if (data.success) {
          document.getElementById("success").style.display = "block";
          document.getElementById("error").style.display = "none";
          document.getElementById("name").value = "";
          document.getElementById("phone").value = "";
        } else {
          showError(data.error || "Sign in failed");
        }
      } catch (e) { showError("Network error. Try again."); }
    }
    function showError(msg) {
      const el = document.getElementById("error");
      el.textContent = msg;
      el.style.display = "block";
      document.getElementById("success").style.display = "none";
    }
  </script>
</body>
</html>`;

  res.set("Content-Type", "text/html");
  res.status(200).send(html);
});

// ─── Sign-in API (called by QR page) ───
app.post("/api/sign-in", async (req, res) => {
  const { registerId, name, phone } = req.body;
  if (!registerId || !name) {
    return res.status(400).json({ success: false, error: "Missing fields" });
  }

  try {
    const participantRef = await db
      .collection("attendanceRegisters").doc(registerId)
      .collection("participants").add({
        name: name.trim(),
        phone: (phone || "").trim(),
        signedInAtMs: Date.now(),
        addedAtMs: Date.now(),
        source: "qr",
      });

    await db
      .collection("attendanceRegisters").doc(registerId)
      .update({ participantCount: admin.firestore.FieldValue.increment(1) });

    res.json({ success: true, participantId: participantRef.id });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// ─── Reminder check (called by cron-job.org hourly) ───
app.post("/api/reminder-check", async (_req, res) => {
  try {
    const now = Date.now();
    const fortyEightHoursAgo = now - 48 * 60 * 60 * 1000;
    const fiftyHoursAgo = now - 50 * 60 * 60 * 1000;

    const reports = await db
      .collection("narrativeReports")
      .where("dateMs", ">=", fiftyHoursAgo)
      .where("dateMs", "<=", fortyEightHoursAgo)
      .where("status", "==", "draft")
      .get();

    const notifications = [];
    reports.forEach((doc) => {
      const data = doc.data();
      if (data.userId) {
        notifications.push({
          userId: data.userId,
          type: "reminder",
          title: "Narrative Report Due",
          body: `Your report for "${data.activityName || "activity"}" is due. Please submit within 24 hours.`,
          createdAtMs: now,
          read: false,
          reportId: doc.id,
        });
      }
    });

    for (const n of notifications) {
      await db.collection("notifications").add(n);
    }

    res.json({ success: true, remindersCreated: notifications.length, _count: notifications.length });
  } catch (e) {
    const msg = String(e.message || "reminder-check failed").substring(0, 300);
    res.status(500).json({ error: msg });
  }
});

// ─── KPI auto-populate (called by cron-job.org daily) ───
app.post("/api/kpi-populate", async (_req, res) => {
  try {
    const now = Date.now();
    const startOfQuarter = new Date();
    startOfQuarter.setMonth(Math.floor(startOfQuarter.getMonth() / 3) * 3, 1);
    startOfQuarter.setHours(0, 0, 0, 0);
    const quarterStartMs = startOfQuarter.getTime();

    const configsSnap = await db.collection("kpiConfigs").get();
    const configs = [];
    configsSnap.forEach((doc) => configs.push({ id: doc.id, ...doc.data() }));

    const reportsSnap = await db
      .collection("narrativeReports")
      .where("dateMs", ">=", quarterStartMs)
      .where("status", "in", ["submitted", "approved"])
      .get();

    const attendanceSnap = await db
      .collection("clockInEvents")
      .where("clockInMs", ">=", quarterStartMs)
      .get();

    const reportsByUser = {};
    reportsSnap.forEach((doc) => {
      const d = doc.data();
      const uid = d.userId;
      if (!reportsByUser[uid]) reportsByUser[uid] = [];
      reportsByUser[uid].push(d);
    });

    const attendanceByUser = {};
    attendanceSnap.forEach((doc) => {
      const d = doc.data();
      const uid = d.userId;
      if (!attendanceByUser[uid]) attendanceByUser[uid] = [];
      attendanceByUser[uid].push(d);
    });

    for (const cfg of configs) {
      const roleGroup = cfg.roleGroup || "volunteer";
      const usersSnap = await db
        .collection("users")
        .where("roleTemplateId", "==", roleGroup)
        .where("status", "==", "active")
        .get();

      for (const userDoc of usersSnap.docs) {
        const uid = userDoc.id;
        const userAttendance = attendanceByUser[uid] || [];
        const userReports = reportsByUser[uid] || [];

        const metricScores = (cfg.metrics || []).map((metric) => {
          let score = 0;
          if (metric.autoSource === "attendance") {
            const daysWorked = userAttendance.filter((a) => a.type === "clockIn").length;
            score = Math.min(daysWorked, metric.target || 1);
          } else if (metric.autoSource === "reports") {
            score = userReports.length;
          }
          return {
            metricId: metric.metric,
            label: metric.label,
            score,
            target: metric.target || 1,
            unit: metric.unit || "count",
            weight: metric.weight || 1,
          };
        });

        const totalWeight = metricScores.reduce((s, m) => s + m.weight, 0);
        const weightedScore = metricScores.reduce((s, m) => s + (m.weight * (m.score / Math.max(m.target, 1))), 0);
        const overallPct = totalWeight > 0 ? Math.round((weightedScore / totalWeight) * 100) : 0;

        const scoreId = `${uid}_${cfg.id}_${quarterStartMs}`;
        await db.collection("kpiScores").doc(scoreId).set({
          id: scoreId,
          userId: uid,
          configId: cfg.id,
          quarterStartMs,
          metricScores,
          overallPercentage: overallPct,
          status: "auto",
          updatedAtMs: now,
        }, { merge: true });
      }
    }

    res.json({ success: true, configsProcessed: configs.length });
  } catch (e) {
    const msg = String(e.message || "kpi-populate failed").substring(0, 300);
    res.status(500).json({ error: msg });
  }
});

// ─── Start server ───
// ─── Catch-all error handler (truncates large responses) ───
app.use((err, _req, res, _next) => {
  const msg = String(err?.message || err || "Internal error").substring(0, 300);
  res.status(500).json({ error: msg });
});

app.listen(PORT, () => {
  console.log(`SALSO Workforce API running on port ${PORT}`);
});
