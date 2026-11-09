# Print Server Deployment with Group Policy

**Lab date:** 9 November 2026  
**Server:** `AD-server2` — Windows Server 2025 (Domain Controller + Print Server), `10.10.10.101`  
**Domain:** `adlab.local`  
**Printer:** EPSON L130 Series  
**Clients:** Windows 11 domain-joined VMs (`AD2-client2` and others)

[← Back to main README](../README.md)

---

## 🎯 Objective

Turn a domain controller into a centralized **print server** and deliver printers to domain users the way it is done in an enterprise:

1. Install the **Print and Document Services** role and manage it from **Print Management**.
2. Publish the same physical printer through **two connection methods**:
   - a **USB-attached** queue (printer physically connected to the Hyper-V host and brought into the server session), and
   - an **IP-based** queue on a **Standard TCP/IP port** (RAW 9100).
3. Load **both x64 and x86 drivers** so 64-bit and 32-bit clients download the right driver automatically.
4. **Share** the printers and **list them in Active Directory**.
5. Deploy the printer automatically with a **Group Policy Preferences (GPP)** printer item linked to the **Accounting OU**.
6. Validate from the client side: **automatic deployment via GPO** and **manual connection via UNC path**.

---

## 🗺️ Design

```text
                       ┌──────────────────────────────────────────────┐
  EPSON L130 (USB) ───►│  Hyper-V host  (DESKTOP-ICE3QC7)              │
                       │      │ Enhanced Session printer redirection   │
                       │      ▼                                        │
                       │  AD-server2 · Windows Server 2025 · .101      │
                       │  ├─ Queue: EPSON L130 Series_shared           │
                       │  │     Port: TS006 (host USB printer)         │
                       │  │     Shared ✔  Listed in AD ✔               │
                       │  ├─ Queue: EPSON L130 Series_NW_shared        │
                       │  │     Port: Standard TCP/IP 10.10.10.103     │
                       │  │           RAW 9100                         │
                       │  └─ Drivers: EPSON L130 x64 + x86 (v2.60.0.0) │
                       └───────────────────┬──────────────────────────┘
                                           │ \\10.10.10.101\EPSON L130 Series_shared
                 ┌─────────────────────────┴─────────────────────────┐
                 ▼                                                   ▼
   GPO "shared_2025_printer_USB"                          Manual connection
   linked to OU: USA › Users › Accounting                 Run → \\10.10.10.101
   User Config › Preferences › Printers (Create)          double-click printer
                 │                                                   │
                 ▼                                                   ▼
     Accounting users get the printer                 Any domain user can connect
     automatically at logon                           (driver pulled from server)
```

| Item | Value |
|---|---|
| Print server | `AD-server2` (`10.10.10.101`) |
| USB queue | `EPSON L130 Series_shared` → port `TS006 (DESKTOP-ICE3QC7: PRN2:# 3)` |
| IP queue | `EPSON L130 Series_NW_shared` → Standard TCP/IP port `10.10.10.103`, RAW, port 9100 |
| Drivers | EPSON L130 Series — Windows x64 & Windows NT x86, v2.60.0.0, Type 3 – User Mode, digitally signed |
| GPO | `shared_2025_printer_USB` → linked to `adlab.local/USA/Users/Accounting` |
| GPP action | **Create** shared printer `\\10.10.10.101\EPSON L130 Series_shared` |

---

## 🛠️ Step-by-Step Process

### Step 1 — Create the USB-attached printer queue

The EPSON L130 is a USB printer connected to the physical Hyper-V host. Hyper-V does not pass USB devices directly to a VM, so the printer is brought into the server through **Enhanced Session printer redirection**, which exposes it as a Terminal Services port (`TS006`). A new printer queue was created on that existing port.

*Print Management → Printers → Add Printer → "Add a new printer using an existing port" → `TS006 (DESKTOP-ICE3QC7: PRN2:# 3)`*

![Existing TS port selected](../images/print-server/01-usb-queue-existing-ts-port.png)

The queue was named and shared as **`EPSON L130 Series_shared`**:

![USB queue name and share](../images/print-server/02-usb-queue-name-and-share.png)

A test page was sent from the server to confirm the queue accepts jobs:

![Server test page](../images/print-server/03-usb-queue-server-test-page.png)

### Step 2 — Share the printer, publish it in AD and add extra drivers

In the printer's **Sharing** tab:

- ✅ **Share this printer**
- ✅ **Render print jobs on client computers** — moves rendering work from the server to the clients
- ✅ **List in the directory** — publishes the printer object in Active Directory so users can search for it
- **Additional Drivers** → x64 and x86 both installed (ARM64 not required in this lab)

![Sharing tab and additional drivers](../images/print-server/04-sharing-ad-publish-additional-drivers.png)

### Step 3 — Add the 32-bit (x86) driver for mixed clients

Only the x64 driver existed on the server at first. The **Add Printer Driver Wizard** was used to add the x86 driver so 32-bit clients can download it automatically via Point and Print.

| | |
|---|---|
| ![Wizard start – only x64 present](../images/print-server/05-add-driver-wizard-start.png) | ![Select x86 processor](../images/print-server/06-add-driver-x86-processor.png) |
| *Wizard start — only the x64 EPSON driver is listed* | *Processor selection — x86* |
| ![Signed Epson driver](../images/print-server/07-add-driver-epson-signed.png) | ![Wizard complete](../images/print-server/08-add-driver-x86-complete.png) |
| *EPSON L130 Series selected — digitally signed* | *EPSON L130 Series, x86, Type 3 – User Mode* |

Result — the same driver name and version (**2.60.0.0**) now exists for **Windows x64** and **Windows NT x86**. Matching names are required for Windows to hand the correct architecture to each client.

![Drivers x64 and x86](../images/print-server/09-drivers-x64-and-x86.png)

### Step 4 — Create a Standard TCP/IP port (IP-connected printer)

To practice the network-printer method, a **Standard TCP/IP port** was created.

*Print Management → Ports → Add Port → Standard TCP/IP Port → New Port*

| | |
|---|---|
| ![New Standard TCP/IP port](../images/print-server/10-new-standard-tcpip-port.png) | ![Port address](../images/print-server/11-tcpip-port-address.png) |
| *Port type: Standard TCP/IP Port* | *Printer IP / port name: `10.10.10.103`* |
| ![Port detection](../images/print-server/12-tcpip-port-detection.png) | ![Port summary RAW 9100](../images/print-server/13-tcpip-port-raw-9100.png) |
| *Windows probes the device* | *Protocol RAW, port 9100, SNMP disabled, Generic Network Card* |

### Step 5 — Create the IP-based printer queue

A second queue was built on the new port and shared as **`EPSON L130 Series_NW_shared`**.

| | |
|---|---|
| ![Existing port 10.10.10.103](../images/print-server/14-ip-queue-existing-port.png) | ![Name and share](../images/print-server/16-ip-queue-name-and-share.png) |
| *Install on existing port `10.10.10.103 (Standard TCP/IP Port)`* | *Printer and share name* |
| ![Printer found summary](../images/print-server/15-ip-queue-printer-found.png) | ![Queue properties](../images/print-server/17-ip-queue-properties.png) |
| *Summary — Standard TCP/IP Port, `10.10.10.103`* | *Queue properties — colour, A4/A5/A6/photo paper sizes* |

### Step 6 — Deploy the printer with Group Policy Preferences

A GPO named **`shared_2025_printer_USB`** was created and configured under:

*User Configuration → Preferences → Control Panel Settings → Printers → New → Shared Printer*

| Setting | Value |
|---|---|
| Action | **Create** |
| Share path | `\\10.10.10.101\EPSON L130 Series_shared` |
| Default printer | Not forced (user keeps control) |

![GPP printers item](../images/print-server/18-gpp-printers-item.png)

![GPP shared printer properties](../images/print-server/19-gpp-printer-create-share-path.png)

The GPO is **linked to the `Accounting` OU** (`adlab.local › USA › Users › Accounting`), so only users in that department receive the printer.

On the right side of the screenshot below, Accounting user **kaviya yadhav (`kaviyayadhav@adlab.local`)** shows **"EPSON L130 Series_shared on 10.10.10.101"** in *Printers & scanners* — delivered automatically by the GPO without any manual action.

![GPO linked to Accounting OU and client result](../images/print-server/20-gpo-linked-accounting-ou-client-result.png)

### Step 7 — Manual connection from a client (UNC path)

To verify the share independently of Group Policy, domain user **eastcharmer** on `AD2-client2` connected manually:

1. **Win + R** → `\\10.10.10.101`
2. The server's shares are listed: `EPSON L130 Series_shared`, `netlogon`, `sysvol`, `Share`, `software deployment`
3. Double-click the printer → Windows downloads the driver from the print server and installs the connection

| | |
|---|---|
| ![Run UNC path](../images/print-server/21-client-run-unc-path.png) | ![Server shares](../images/print-server/22-client-server-shares.png) |
| *Run → `\\10.10.10.101`* | *Shares published by the server* |
| ![Connecting to printer](../images/print-server/23-client-connecting-printer.png) | ![Print dialog](../images/print-server/24-client-print-dialog.png) |
| *"Connecting to EPSON L130 Series_shared on 10.10.10.101"* | *Shared printer selectable in the print dialog* |

### Step 8 — End-to-end test print

A test document was printed from the client. The job travelled from the client to the server and appeared in the server's queue (**Jobs In Queue: 1** on `EPSON L130 Series_shared`, matching **"1 document(s) in queue"** on the client).

![Client test document](../images/print-server/25-client-test-document.png)

![Job visible in server queue](../images/print-server/26-client-job-in-server-queue.png)

---

## ✅ Results

| Test | Result |
|---|---|
| x64 + x86 drivers on the print server | ✔ Both installed, same name and version |
| Printer shared and listed in Active Directory | ✔ |
| Standard TCP/IP port (RAW 9100) + IP queue | ✔ Created and shared |
| GPO deployment to Accounting OU user | ✔ Printer appeared automatically for `kaviyayadhav` |
| Manual connection via `\\10.10.10.101` | ✔ Driver downloaded and printer installed for `eastcharmer` |
| Print job from client reaches server queue | ✔ Job visible in Print Management |

---

## 🧠 Key Concepts Demonstrated

- **Print server role & Print Management console** — central management of drivers, ports, queues and forms.
- **Port types** — Local/TS-redirected ports vs. **Standard TCP/IP ports** (RAW 9100, the most common protocol for network printers).
- **Hyper-V limitation** — VMs have no direct USB passthrough; a host-attached USB printer reaches a VM through **Enhanced Session redirection** (TS ports), which exist only while that session is connected.
- **Cross-architecture drivers** — x64 and x86 drivers must share the exact same name for Point and Print to serve the right one.
- **Client-side rendering** and **publishing printers in AD**.
- **Group Policy Preferences – Printers** — the *Create* action, share paths, default-printer behaviour, and **OU-based targeting**.
- **UNC-path connections** and Point and Print driver download from the server.
- **Job-flow troubleshooting** — following a job from the client spooler to the server queue.
