# Iron-Gate
𝘐𝘳𝘰𝘯𝘎𝘢𝘵𝘦 𝘪𝘴 𝘢 𝘻𝘦𝘳𝘰-𝘵𝘳𝘶𝘴𝘵 𝘯𝘦𝘵𝘸𝘰𝘳𝘬 𝘬𝘪𝘭𝘭 𝘴𝘸𝘪𝘵𝘤𝘩 𝘧𝘰𝘳 𝘓𝘪𝘯𝘶𝘹. 𝘐𝘵 𝘪𝘯𝘴𝘵𝘢𝘯𝘵𝘭𝘺 𝘴𝘭𝘢𝘮𝘴 𝘵𝘩𝘦 𝘣𝘳𝘢𝘬𝘦𝘴 𝘵𝘩𝘳𝘰𝘸𝘪𝘯𝘨 𝘵𝘩𝘦 𝘴𝘺𝘴𝘵𝘦𝘮 𝘪𝘯𝘵𝘰 𝘢 𝘩𝘢𝘳𝘥𝘦𝘯𝘦𝘥 𝘢𝘪𝘳-𝘨𝘢𝘱𝘱𝘦𝘥 𝘴𝘵𝘢𝘵𝘦 𝘰𝘳 𝘩𝘪𝘵𝘴 𝘵𝘩𝘦 𝘨𝘢𝘴 𝘵𝘰 𝘳𝘦𝘴𝘵𝘰𝘳𝘦 𝘯𝘦𝘵𝘸𝘰𝘳𝘬𝘪𝘯𝘨 𝘢𝘵 𝘸𝘪𝘭𝘭.

**Description**

IronGate is a rapid-response network lockdown tool built for SOC operators, field analysts, and cybersecurity professionals. It is engineered for digital crisis scenarios where immediate containment is required. IronGate disables all network interfaces, kills DNS and routing, flushes the firewall, and even removes NIC drivers to completely sever system connectivity — all within seconds. It operates quietly, logs everything, and provides verifiable integrity via SHA256 hashing.

Use it to isolate compromised systems, perform live incident containment, or establish air-gapped trust zones under your control.

**Table of Contents**

• Installation

• Usage

• Features

• Tests

• Disclaimer

**Installation**

1. Download the iron_gate.sh script and place it in a secure directory.
2. Make it executable: chmod +x iron_gate.sh
3. (Optional) Add it to your system $PATH or run it directly from the working directory with: ./iron_gate.sh

**Usage**

To use this program, follow these steps:

1. Run the script as a user with sudo privileges: sudo ./iron_gate.sh
2. Choose whether to extend sudo privileges for 5 minutes.
3. Review available network interfaces.
4. Select the lockdown level from 1 (light), to 5 (complete blackout), or restoration levels 6–8 to undo actions.
5. All operations are logged to ~/.irongate_log.csv in clean, timestamped format.

**Features**

Air-Gap Lockdown:

• Disables WiFi, Ethernet, and RF hardware.

• Removes DNS, flushes IP routes.

• Drops all inbound/outbound/forward firewall rules.

• Unloads kernel modules for NIC drivers.

• Disables NetworkManager for total blackout.

**Logging & Evidence:**

• Logs every user action, command, and result to a hidden CSV file.
• Format is compatible with LibreOffice/Excel.
• Useful for auditing, chain-of-custody, or compliance reports.

**Integrity Check via Hash:**

• On launch you may verify the hash manually: sha256sum iron_gate.sh

• Compare against: c54514043c7ba314ae876d290ab1d0c49aabea5fb2fb7a34812ea9d5f5c6d801

**Tests**

QA Rating: 

• Passed on Arch Linux.

• Interfaces dropped successfully.

• DNS flushed.

• Firewall rules verified.

• Drivers removed and restored.

• Logging intact and cleanly formatted.

• SHA256 integrity verified.

**Disclaimer**

This tool is destructive by design. It is intended for incident response and containment, not casual use.

The author of IronGate assumes no liability or responsibility for damage, data loss, connectivity disruption, system misconfiguration, misuse, or illegal application of this software.

You use this tool entirely at your own risk. Do not run IronGate on production systems unless you fully understand its consequences.
