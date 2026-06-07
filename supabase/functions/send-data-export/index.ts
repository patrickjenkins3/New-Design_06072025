import { serve } from "https://deno.land/std@0.192.0/http/server.ts";

serve(async (req) => {
  // ✅ CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*", // DO NOT CHANGE THIS
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "*" // DO NOT CHANGE THIS
      }
    });
  }

  try {
    const { email, filename, csvContent, userFullName } = await req.json();

    if (!email || !filename || !csvContent) {
      throw new Error('Missing required fields: email, filename, or csvContent');
    }

    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    if (!resendApiKey) {
      throw new Error('RESEND_API_KEY is not configured');
    }

    // Create email content
    const htmlContent = `
      <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f8fafc;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 12px 12px 0 0;">
          <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 600;">CollabFuture</h1>
          <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 16px;">Your Data Export is Ready</p>
        </div>
        
        <div style="background: white; padding: 30px; border-radius: 0 0 12px 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
          <p style="color: #1f2937; font-size: 16px; line-height: 1.6; margin-bottom: 20px;">
            Hello ${userFullName || 'there'},
          </p>
          
          <p style="color: #374151; font-size: 14px; line-height: 1.6; margin-bottom: 25px;">
            Your data export has been successfully generated and is attached to this email. The file contains your latest information from CollabFuture in CSV format, making it easy to import into spreadsheet applications.
          </p>
          
          <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; margin-bottom: 25px; border-left: 4px solid #667eea;">
            <h3 style="color: #1f2937; font-size: 16px; margin: 0 0 10px 0; font-weight: 600;">Export Details:</h3>
            <ul style="color: #4b5563; font-size: 14px; margin: 0; padding-left: 20px; line-height: 1.6;">
              <li>File: ${filename}</li>
              <li>Generated: ${new Date().toLocaleDateString()} at ${new Date().toLocaleTimeString()}</li>
              <li>Format: CSV (Comma Separated Values)</li>
            </ul>
          </div>
          
          <p style="color: #6b7280; font-size: 13px; line-height: 1.6; margin-bottom: 20px;">
            <strong>Privacy Note:</strong> This file contains your personal data. Please store it securely and delete it when no longer needed.
          </p>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="https://collabfuture.com/profile-settings" 
               style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-decoration: none; padding: 12px 30px; border-radius: 8px; font-weight: 600; font-size: 14px;">
              Manage Data Settings
            </a>
          </div>
          
          <hr style="border: none; height: 1px; background: #e5e7eb; margin: 30px 0;">
          
          <p style="color: #9ca3af; font-size: 12px; text-align: center; margin: 0;">
            This email was sent by CollabFuture. If you have any questions, please contact our support team.
          </p>
        </div>
      </div>
    `;

    // Prepare attachment
    const attachment = {
      filename: filename,
      content: btoa(csvContent), // Base64 encode the CSV content
      type: 'text/csv'
    };

    // Send email using Resend API
    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'onboarding@resend.dev',
        to: [email],
        subject: `CollabFuture Data Export - ${filename}`,
        html: htmlContent,
        attachments: [attachment]
      }),
    });

    if (!emailResponse.ok) {
      const errorData = await emailResponse.text();
      throw new Error(`Email service error: ${errorData}`);
    }

    const emailResult = await emailResponse.json();

    return new Response(JSON.stringify({
      success: true,
      message: 'Data export sent successfully',
      emailId: emailResult.id,
      filename: filename
    }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // DO NOT CHANGE THIS
      }
    });

  } catch (error) {
    console.error('Send data export error:', error);
    return new Response(JSON.stringify({
      error: error.message,
      success: false
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // DO NOT CHANGE THIS
      }
    });
  }
});