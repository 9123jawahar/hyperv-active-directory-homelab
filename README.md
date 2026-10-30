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

## 🗺️ Architectural Topology & Network Mapping

To maximize host resource efficiency (**16GB RAM constraints**), the entire lab utilizes **Hyper-V Dynamic Memory management** across an completely isolated Virtual Switch fabric (`vEthernet AD-lab-switch`).

Initial commit: Home lab documentation
