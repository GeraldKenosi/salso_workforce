const {onCall} = require("firebase-functions/v2/https");
const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {setGlobalOptions} = require("firebase-functions");
const admin = require("firebase-admin");
const {Storage} = require("@google-cloud/storage");
const https = require("https");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

const storage = new Storage();
const bucketName = "salso-workforce.firebasestorage.app";

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

// ─── Existing: HR create user ───
exports.hrCreateUser = onCall(async (request) => {
  const data = request.data;
  const {fullName, email, roleTemplateId, programmeId, teamId} = data;

  if (!fullName || !email || !roleTemplateId) {
    throw new Error("Missing required fields: fullName, email, roleTemplateId");
  }

  const tempPassword = generateTempPassword();
  const user = await admin.auth().createUser({
    email: email.trim().toLowerCase(),
    password: tempPassword,
    displayName: fullName.trim(),
    disabled: false,
  });

  await admin.firestore().collection("users").doc(user.uid).set({
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

  return {
    uid: user.uid,
    email: user.email,
    message: "User created successfully. Password reset email has been sent.",
  };
});

// ─── File transfer: Firebase Storage → SharePoint ───
exports.fileTransferToSharePoint = onCall(async (request) => {
  const {storagePath, sharePointPath, fileName} = request.data;
  if (!storagePath || !sharePointPath || !fileName) {
    throw new Error("Missing required fields: storagePath, sharePointPath, fileName");
  }

  const config = sharePointConfig();
  const file = storage.bucket(bucketName).file(storagePath);
  const [exists] = await file.exists();
  if (!exists) throw new Error("File not found in storage");

  const [contents] = await file.download();
  const token = await getGraphToken(config);
  const result = await uploadToSharePoint(token, config, sharePointPath, contents, fileName);

  return {success: true, sharePointUrl: result?.webUrl || "Uploaded"};
});

// ─── QR self-service: HTML page for participant sign-in ───
exports.qrSelfService = onRequest(async (req, res) => {
  const registerId = req.query.registerId || "";
  const registerName = req.query.registerName || "Attendance";

  if (!registerId) {
    res.status(400).send("Missing registerId parameter");
    return;
  }

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
        const r = await fetch("/api/signIn", {
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

  function escapeHtml(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  }

  res.set("Content-Type", "text/html");
  res.status(200).send(html);
});

// ─── QR sign-in API endpoint (called by the HTML page) ───
exports.signIn = onRequest(async (req, res) => {
  if (req.method !== "POST") { res.status(405).send("Method not allowed"); return; }

  const {registerId, name, phone} = req.body;
  if (!registerId || !name) {
    res.status(400).json({success: false, error: "Missing fields"});
    return;
  }

  try {
    const participantRef = await admin.firestore()
      .collection("attendanceRegisters").doc(registerId)
      .collection("participants").add({
        name: name.trim(),
        phone: (phone || "").trim(),
        signedInAtMs: Date.now(),
        addedAtMs: Date.now(),
        source: "qr",
      });

    await admin.firestore()
      .collection("attendanceRegisters").doc(registerId)
      .update({participantCount: admin.firestore.FieldValue.increment(1)});

    res.json({success: true, participantId: participantRef.id});
  } catch (e) {
    res.status(500).json({success: false, error: e.message});
  }
});

// ─── 48h reminder: scheduled every hour ───
exports.reminder48h = onSchedule("0 * * * *", async () => {
  const now = Date.now();
  const fortyEightHoursAgo = now - 48 * 60 * 60 * 1000;
  const fiftyHoursAgo = now - 50 * 60 * 60 * 1000;

  // Find narrative reports created ~48h ago that have no submission
  const reports = await admin.firestore()
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
    await admin.firestore().collection("notifications").add(n);
  }
});

// ─── KPI auto-populate: scheduled daily ───
exports.kpiAutoPopulate = onSchedule("0 2 * * *", async () => {
  const now = Date.now();
  const startOfQuarter = new Date();
  startOfQuarter.setMonth(Math.floor(startOfQuarter.getMonth() / 3) * 3, 1);
  startOfQuarter.setHours(0, 0, 0, 0);
  const quarterStartMs = startOfQuarter.getTime();

  // Get all active KPI configs
  const configsSnap = await admin.firestore().collection("kpiConfigs").get();
  const configs = [];
  configsSnap.forEach((doc) => configs.push({id: doc.id, ...doc.data()}));

  // Get reports and attendance this quarter
  const reportsSnap = await admin.firestore()
    .collection("narrativeReports")
    .where("dateMs", ">=", quarterStartMs)
    .where("status", "in", ["submitted", "approved"])
    .get();

  const attendanceSnap = await admin.firestore()
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

  // For each config, calculate auto-source metrics and write scores
  for (const cfg of configs) {
    const roleGroup = cfg.roleGroup || "volunteer";
    const usersSnap = await admin.firestore()
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

      // Upsert score for this user + quarter
      const scoreId = `${uid}_${cfg.id}_${quarterStartMs}`;
      await admin.firestore().collection("kpiScores").doc(scoreId).set({
        id: scoreId,
        userId: uid,
        configId: cfg.id,
        quarterStartMs,
        metricScores,
        overallPercentage: overallPct,
        status: "auto",
        updatedAtMs: now,
      }, {merge: true});
    }
  }
});

// ─── Legacy function exports ───
exports.generateTempPassword = generateTempPassword;
