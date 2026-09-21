const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

exports.classifyIssue = functions.firestore
  .document("issues/{issueId}")
  .onCreate(async (snap, context) => {
    const issue = snap.data();

    const text = `${issue.title}. ${issue.description}`;

    const labels = [
      "Pothole",
      "Garbage",
      "Water Leakage",
      "Street Light",
      "Road Damage",
      "Other",
    ];

    // 🔐 AI API CALL (example – OpenAI style)
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer YOUR_API_KEY_HERE`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content:
              "Classify the issue into one of these categories ONLY: " +
              labels.join(", "),
          },
          {
            role: "user",
            content: text,
          },
        ],
      }),
    });

    const data = await response.json();

    const predicted = data.choices[0].message.content.trim();

    // Save AI result
    await snap.ref.update({
      aiSuggestedType: predicted,
      aiUsed: true,
      aiConfidence: 0.9, // optional static confidence
    });

    return null;
  });
