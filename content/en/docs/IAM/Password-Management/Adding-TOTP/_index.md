---
title: "Adding a Time-based One-time Password With Automatic Bitwarden Authentication"
date: 2023-02-01
linkTitle: "Adding a TOTP"
weight: 50
description: >
  Bitwarden can act as your TOTP authenticator which, in many cases, can make TOTP authentication automatic.
---

Using Bitwarden as your TOTP authenticator is not only convenient but is also the vehnicle for sharing credentials on sites that require MFA.
But remember that this kind of sharing should _only_ between trusted parties.

### Example Enabling Bitwarden Authenticator as the TOTP Genreator for Zoom


1. Login to Zoom
2. Got to the Personal -> Profile
3. Under two-factor authentication
4. Verify On or Click Turn On
5. Authentication App, click Set Up


{{< imgproc adding_totp_step_1 Resize "500x" >}}
{{< /imgproc >}}


6. Enter your Zoom password
7. Click Next

{{< imgproc adding_totp_step_2 Resize "500x" >}}
{{< /imgproc >}}

8. A QR code will appear on your screen
9. If you don’t have a phone with Bitwarden installed, click the “I can’t scan...” link and follow the instructions.
10. Now with the phone...

{{< imgproc adding_totp_step_3 Resize "500x" >}}
{{< /imgproc >}}

11. Open Bitwarden
12. Open the Zoom.com login item
13. Click Edit
14. Click TOTP
15. Aim the camera at the QR code on the computer’s screen.
It will scan automatically

{{< imgproc adding_totp_step_4 Resize "500x" >}}
{{< /imgproc >}}

16. Once the scan is complete, the TOTP field will have a long URL starting with otpauth://
17. Click Save (upper right hand corner)
18. The Verification code is now a code and will change very 30 seconds.
19. Note countdown timer, and copy icon

{{< imgproc adding_totp_step_5 Resize "500x" >}}
{{< /imgproc >}}

Now, you may log into Zoom by copy-and-paste the user name and password from Bitwarden to Zoom. You will ten be challenged for the Verification code. Provide the code shown in Bitwarden.

{{< imgproc ZoomLogin Resize "700x" >}}
{{< /imgproc >}}
