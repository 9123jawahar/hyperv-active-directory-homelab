# Enterprise-Grade Active Directory & Network Engineering Hybrid Home Lab

## 📌 Project Overview
An isolated, multi-subnet enterprise environment engineered on a single hypervisor host. This project simulates a corporate infrastructure deployment featuring hierarchical domain architectures, distinct firewall zones, secure identity management, and automated client onboarding. 

The lab serves as a live sandbox for testing **Group Policy Management, Active Directory Replication, Core Infrastructure Services (DNS/DHCP), and Network Troubleshooting Remediation.**

---

## 🛠️ Core Infrastructure & Technical Competencies
*   **Hypervisor Engine:** Microsoft Hyper-V
*   **Perimeter Gateway & Firewall:** pfSense (v2.7.2)
*   **Identity & Directory Services:** Active Directory Domain Services (AD DS), DNS, DHCP
*   **Operating Systems:** Windows Server 2025 (Primary DC), Windows Server 2022 (Replication DC), Windows 10/11 Enterprise Clients
*   **Security Frameworks:** Windows LAPS (Local Administrator Password Solution), Restricted Group Policy Objects (GPOs)

---
[ Physical Host (Wi-Fi Internet Access Connection) ]
|
v  (Unshared External Virtual Switch Interface)
[ pfSense Virtual Appliance ]
|
+-------------+-------------+  (Isolated LAN Private Network)
|                           |
[ Server 2025 - Primary DC ]    [ Server 2022 - Replica DC ]
• IP: 10.10.10.100              - IP: 10.10.10.200
• Role: DNS, DHCP, AD DS        - Role: DNS, AD DS Replication
|
+---------------------------+
|
[ Enterprise Workstations ]
- Client 1, Client 2, Client 3
- Managed dynamically via centralized DHCP


## 🚀 Key Deployment Phases


1. Perimeter Segmentation & Edge Routing

• Configured a dedicated pfSense virtual appliance to serve as the secure edge gateway.
• Implemented an unshared External Virtual Switch bound directly to the physical Wi-Fi hardware to isolate host OS network traffic from the lab infrastructure.
• Established a private virtual switch fabric (Lab-LAN) to completely hide the Active Directory environment behind the pfSense routing layer.

2. Identity Infrastructure & Directory Design

• Provisioned a forest root domain (adlab.local) on a primary Windows Server 2025 instance.
• Structured a standardized Active Directory schema utilizing dedicated Organizational Units (OUs) separating Lab-Workstations from core directory security groups.
• Deployed a Windows Server 2022 instance as a secondary Domain Controller, configuring Active Directory Replication Topologies and validating cross-server schema health checks.

3. Automated Configuration Services (DHCP & Reverse Lookup DNS)

• De-conflicted edge routing by migrating default scopes to a centralized DHCP server on the Domain Controller (10.10.10.100).
• Configured DHCP Scope Option 006 to enforce the centralized Primary Domain Controller as the sole authoritative DNS authority for clients.
• Constructed corresponding DNS Reverse Lookup Zones (PTR records) to validate bidirectional host resolution, essential for stable domain controller sync states.

Initial commit: Home lab documentation
