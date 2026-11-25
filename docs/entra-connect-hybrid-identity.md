# Hybrid Identity: Syncing On-Premises AD to Microsoft Entra ID with Entra Connect Sync

**Lab date:** 23–24 November 2026  
**On-premises:** `adlab.local`. Entra Connect Sync installed on **AD-server3** (Windows Server 2025, `10.10.10.102`)  
**Cloud:** Microsoft Entra ID tenant **Default Directory** (`9123jawahargmail.onmicrosoft.com`)

[← Back to main README](../README.md)

---

## 🎯 Objective

Connect the on-premises Active Directory to the cloud so that users created in AD automatically appear in **Microsoft Entra ID** (formerly Azure AD), the identity platform behind Microsoft 365 and Azure. This is how most organisations run a **hybrid identity** model.

| Item | Configuration |
|---|---|
| Sync tool | **Microsoft Entra Connect Sync** (Express Settings) on AD-server3 |
| Sign-in method | **Password Hash Synchronization (PHS)** |
| Cloud account used by the wizard | `syncadmin@…onmicrosoft.com`, **Hybrid Identity Administrator** |
| On-premises account used by the wizard | `ADLAB\administrator` (Enterprise Admin). The wizard **created its own AD connector account** |
| Source anchor | **mS-DS-ConsistencyGuid** |
| Sync scope | All users and devices |
| Licensing | **Microsoft Entra ID P1** trial (25 licences), assigned **directly and through a synced AD group** |

```text
   ON-PREMISES (adlab.local)                                   CLOUD (Microsoft Entra ID)
 ┌──────────────────────────────┐                        ┌───────────────────────────────────┐
 │ AD DS: AD-server1/2/3        │                        │ Tenant: 9123jawahargmail.          │
 │  OU=USA › Users › IT …       │                        │         onmicrosoft.com            │
 │  users, groups (Admin_IT)    │                        │                                   │
 │            │                 │   HTTPS (outbound)     │  Users  (17 → 19 synced)           │
 │  AD-server3: Entra Connect   ├───────────────────────►│  Groups (Admin_IT)                 │
 │  Sync  · PHS · every ~30 min │                        │  Entra ID P1 licences              │
 │  AD connector account        │                        │   └─ group-based: Admin_IT         │
 └──────────────────────────────┘                        └───────────────────────────────────┘
```

---

## 🛠️ Step-by-Step Process

### Step 1 — Prepare the Entra ID tenant

Signed in to the **Azure portal** and confirmed the tenant: **Default Directory**, domain **`9123jawahargmail.onmicrosoft.com`**.

![Entra tenant](../images/entra-connect/01-entra-tenant-directory.png)

Created two cloud-only admin accounts, following **least privilege**:

| Account | Role | Purpose |
|---|---|---|
| `admin@…onmicrosoft.com` | **Global Administrator** | Tenant administration and licensing |
| `syncadmin@…onmicrosoft.com` | **Hybrid Identity Administrator** | The lowest role that can configure Entra Connect, so the sync setup does not need a Global Admin |

| | |
|---|---|
| ![Global admin user](../images/entra-connect/02-entra-global-admin-user.png) | ![Hybrid identity admin user](../images/entra-connect/03-entra-hybrid-identity-admin-user.png) |
| *`admin`: Global Administrator* | *`syncadmin`: Hybrid Identity Administrator* |

*(Passwords removed from the screenshots.)*

### Step 2 — Prepare on-premises UPNs

`adlab.local` is not a routable internet domain, so it **cannot be verified** in Entra ID. Users signing in with `user@adlab.local` would not be able to use those credentials in the cloud.

To fix this, the tenant's domain `9123jawahargmail.onmicrosoft.com` was added as an **alternative UPN suffix** in AD (*AD Domains and Trusts › Properties › UPN Suffixes*). User **Test 1** was then switched to `Test1@9123jawahargmail.onmicrosoft.com` in ADUC (*Account* tab).

![On-premises UPN suffix](../images/entra-connect/04-onprem-upn-suffix-onmicrosoft.png)

### Step 3 — Download and install Entra Connect Sync

On **AD-server3**, signed in to the portal as `syncadmin` → *Microsoft Entra ID › Microsoft Entra Connect › Get started › **Download Connect Sync Agent***, then ran the installer.

| | |
|---|---|
| ![Download agent](../images/entra-connect/05-download-connect-sync-agent.png) | ![Required components](../images/entra-connect/06-required-components.png) |
| *Download Connect Sync Agent* | *Required components: installs the sync service and a local SQL Express database* |

### Step 4 — Choose the sign-in method

Selected **Password Hash Synchronization**. A hash of each user's AD password hash is synced to Entra ID, so users sign in to Microsoft 365 / Azure with the **same password** as on-premises. Cloud sign-in also keeps working if the on-premises DCs are offline.

![User sign-in: Password Hash Synchronization](../images/entra-connect/07-user-signin-password-hash-sync.png)

| Method | How sign-in works |
|---|---|
| **Password Hash Sync** (chosen) | Entra ID checks the password itself, using a synced hash |
| Pass-through Authentication | Entra ID forwards the check to an on-premises agent |
| Federation (AD FS / PingFederate) | Sign-in is redirected to an on-premises federation server |

### Step 5 — Connect to Entra ID and to AD

| | |
|---|---|
| ![Connect to Entra as syncadmin](../images/entra-connect/08-connect-to-entra-syncadmin.png) | ![AD forest account](../images/entra-connect/09-ad-forest-account-enterprise-admin.png) |
| *Signed in to Entra ID as `syncadmin` (Hybrid Identity Administrator)* | *AD forest account: **Create new AD account**, authorised with `ADLAB\administrator` (Enterprise Admin)* |

Choosing **Create new AD account** lets the wizard create a dedicated **AD DS connector account** (`MSOL_…`) with only the permissions sync needs. The Enterprise Admin credentials are used once for setup and are not stored.

![Directory connected](../images/entra-connect/10-connect-directories-adlab.png)

### Step 6 — UPN suffixes and user matching

The wizard listed the on-premises UPN suffixes. Neither `adlab.local` nor `9123jawahargmail.onmicrosoft.com` showed as a verified custom domain. **"Continue without matching all UPN suffixes to verified domains"** was selected, with `userPrincipalName` as the Entra username.

![Entra sign-in configuration](../images/entra-connect/11-entra-signin-upn-suffixes.png)

**Identifying users:** users exist once across all directories, and **Azure manages the source anchor**. The source anchor is the permanent link between an AD object and its cloud object.

![Identifying users](../images/entra-connect/12-identifying-users-source-anchor.png)

### Step 7 — Filtering and finish

Synced **all users and devices**. A pilot group could be used here instead.

| | |
|---|---|
| ![Filter users and devices](../images/entra-connect/13-filter-users-devices.png) | ![Configuration complete](../images/entra-connect/14-configuration-complete.png) |
| *Synchronize all users and devices* | *Configuration complete. Source anchor: **mS-DS-ConsistencyGuid*** |

### Step 8 — Verify the first sync

In *Entra ID › Users*, **17 users** were present, including the synced AD users (kaviya yadhav, Meer Ali, Sakura Kinimoto, Talha N, Test 1, Test 3, Test User1 …). They now carry `@9123jawahargmail.onmicrosoft.com` UPNs.

![17 users synced](../images/entra-connect/15-entra-users-synced-17.png)

### Step 9 — Test ongoing sync with new users

Created two new users in **`adlab.local/USA/Users/IT`**, each with a different UPN suffix:

| | |
|---|---|
| ![Test 2 with adlab.local](../images/entra-connect/16-new-user-test2-adlab-local.png) | ![Test 4 with onmicrosoft](../images/entra-connect/17-new-user-test4-onmicrosoft.png) |
| *Test 2: `test2@adlab.local` (non-routable suffix)* | *Test 4: `test4@9123jawahargmail.onmicrosoft.com`* |

After the next sync cycle, Entra ID showed **19 users**, with **Test 2** and **Test 4** both present:

![19 users synced](../images/entra-connect/18-entra-users-synced-19.png)

Test 2 appears in Entra as `test2@9123jawahargmail.onmicrosoft.com`, not `test2@adlab.local`. When an on-premises UPN suffix is **not a verified domain**, Entra ID replaces it with the tenant's default `onmicrosoft.com` domain. The user is synced, but their cloud sign-in name differs from their on-premises one, which is why matching UPN suffixes (Step 2) matter.

The default sync cycle runs every **30 minutes**. A delta sync can be forced on the sync server with:

```powershell
Start-ADSyncSyncCycle -PolicyType Delta
```

### Step 10 — Licensing with Microsoft Entra ID P1

Activated a **Microsoft Entra ID P1 trial** (25 licences, 1 month) in the **Microsoft 365 admin center**. P1 adds features such as Conditional Access, group-based licensing and self-service password reset with writeback.

**Direct assignment:** licences assigned to `admin`, `Ahmed N` and `east charmer` (**3/25**).

![Entra ID P1: 3 licences assigned](../images/entra-connect/19-entra-id-p1-licenses-assigned.png)

**Group-based licensing:** assigned the licence to the **`Admin_IT`** group, which is **synced from on-premises AD**. Members such as **Don Jones** and **Test 1** received **Azure Active Directory Premium P1** automatically. Their licence panel says *"This license is inherited through a group"*. Total usage rose to **5/25**.

![Group-based licensing through Admin_IT](../images/entra-connect/20-group-based-licensing-admin-it.png)

With group-based licensing, **adding a user to an AD group on-premises** is enough to license them in the cloud after the next sync, with no manual licence work.

---

## ✅ Results

| Check | Result |
|---|---|
| Entra Connect Sync installed and configured | ✔ Configuration complete, sync initiated |
| On-premises users visible in Entra ID | ✔ 17 users after the first sync |
| New AD users synced automatically | ✔ Test 2 and Test 4 appeared (19 users) |
| UPN suffix behaviour verified | ✔ Unverified `adlab.local` suffix replaced with `onmicrosoft.com` in the cloud |
| Entra ID P1 licences | ✔ Direct (3) and group-based through synced `Admin_IT` group (5/25 total) |

---

## 🧠 Key Concepts Demonstrated

- **Hybrid identity**: AD as the source of authority, Entra ID as the cloud identity, Entra Connect Sync as the bridge.
- **Sign-in options**: Password Hash Sync vs Pass-through Authentication vs Federation, and why PHS is the most common choice.
- **Least-privilege admin roles**: Hybrid Identity Administrator for sync setup, Global Administrator kept separate.
- **AD DS connector account** created by the wizard, with Enterprise Admin used only during setup.
- **UPN suffixes and verified domains**: why `.local` cannot be used for cloud sign-in, and the alternative UPN suffix fix.
- **Source anchor (`mS-DS-ConsistencyGuid`)**: the permanent link between on-premises and cloud objects.
- **Sync filtering** (all objects vs pilot group) and the **30-minute sync cycle** (`Start-ADSyncSyncCycle`).
- **Microsoft Entra ID P1 licensing**: direct vs **group-based licensing** using an on-premises group synced to the cloud.
