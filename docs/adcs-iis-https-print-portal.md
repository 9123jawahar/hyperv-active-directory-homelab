# Internal HTTPS with AD Certificate Services & IIS (Print Server Status Page)

**Lab date:** 16 November 2026  
**Server:** `AD-SERVER2.adlab.local` (`10.10.10.101`): Windows Server 2025, **AD CS Enterprise Root CA**, DNS, IIS 10  
**Website:** `https://printserver.adlab.local`  
**Monitored device:** network printer `10.10.10.103`

[← Back to main README](../README.md)

---

## 🎯 Objective

Publish an internal web page that shows whether the network printer is reachable, served over **HTTPS with a certificate issued by the domain's own CA**, so that domain-joined clients trust it with no browser warnings.

| Component | Value |
|---|---|
| Certificate Authority | AD CS **Enterprise Root CA** on `AD-SERVER2` |
| Certificate template | **Web Server** |
| DNS record | Host (A) `printserver.adlab.local` → `10.10.10.101` |
| Site content | HTML/JavaScript status page in `C:\inetpub\wwwroot\printserver` |
| Binding | HTTPS, port 443, host name `printserver.adlab.local`, **SNI enabled** |

```text
 Domain client ──https://printserver.adlab.local──► DNS (A) 10.10.10.101 ──► IIS on AD-SERVER2
        ▲                                                                   │  site: printserver (443, SNI)
        │ trusts certificate because the                                    │  cert issued by AD CS
        └── Enterprise Root CA is published in AD to every domain member ◄──┘
                                                                            │
                                                         status page checks printer 10.10.10.103
```

---

## 🛠️ Process

### 1 — Choose the certificate source

- Reviewed how a **Certificate Signing Request (CSR)** is created in IIS 10: *Server Certificates › Create Certificate Request*, producing a Base-64 block between `-----BEGIN NEW CERTIFICATE REQUEST-----` and `-----END NEW CERTIFICATE REQUEST-----`.
- **Decision:** public CAs (DigiCert, ZeroSSL, Let's Encrypt) **cannot issue certificates for `.local` names**, because they are not publicly resolvable or verifiable. **AD CS** was used instead. An Enterprise CA's root certificate is distributed automatically to all domain members, so its certificates are trusted inside the domain.

### 2 — Submit the CSR through AD CS Web Enrollment (`/certsrv`)

Getting to the enrollment portal produced three issues, each resolved:

| # | Symptom | Cause | Resolution |
|---|---|---|---|
| 1 | `http://ad-server2.adlab.local/certsrv` → **HTTP 403.4 Forbidden** | The `certsrv` virtual directory has **Require SSL** enabled | Use HTTPS |
| 2 | `https://adlab.local/certsrv` → **certificate name mismatch** | The existing certificate on Default Web Site was issued to `AD-server2.adlab.local`, not `adlab.local` | Browse to the exact name in the certificate |
| 3 | Adding another port 443 binding → **IP/port conflict** warning | Default Web Site already had a 443 binding on the same IP | Reused the existing binding instead of duplicating it |

Final working URL: **`https://ad-server2.adlab.local/certsrv`** → *Request a certificate › advanced certificate request* → pasted the CSR → template **Web Server** → downloaded the issued `.cer`.

### 3 — DNS record for the site

In **DNS Manager**, created a Host (A) record in the `adlab.local` zone:

```text
printserver.adlab.local   A   10.10.10.101
```

### 4 — Website content

Deployed an **HTML/JavaScript status page** to `C:\inetpub\wwwroot\printserver` that checks reachability of the network printer at **`10.10.10.103`**.

### 5 — Complete the certificate and bind HTTPS in IIS

1. *IIS Manager › Server Certificates › **Complete Certificate Request*** and selected the issued `.cer`.
2. Created the `printserver` site and added an **HTTPS binding**: port **443**, host name **`printserver.adlab.local`**, **Require Server Name Indication** checked, with the new certificate selected.
3. **SNI** lets several HTTPS sites share one IP address and port 443. IIS chooses the certificate from the host name the browser sends. That is how `printserver` coexists with the existing 443 binding on Default Web Site.

### 6 — Browser requirement: Subject Alternative Name (SAN)

Modern browsers (Chrome, Edge) **ignore the certificate's Common Name** and accept a certificate only if the host name appears in its **Subject Alternative Name (SAN)** extension. A certificate for `printserver.adlab.local` should therefore be requested with a SAN. This can be done with `certreq` and an `.inf` file:

```ini
; printserver.inf
[NewRequest]
Subject = "CN=printserver.adlab.local"
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
RequestType = PKCS10

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "dns=printserver.adlab.local&"
_continue_ = "dns=ad-server2.adlab.local"

[RequestAttributes]
CertificateTemplate = WebServer
```

```cmd
certreq -new printserver.inf printserver.req
certreq -submit -config "AD-SERVER2.adlab.local\<CA-Name>" printserver.req printserver.cer
certreq -accept printserver.cer
```

---

## 🧠 Key Concepts Demonstrated

- **PKI basics**: CSR → CA signs → certificate issued → installed with its private key.
- **Public vs internal CAs**, and why `.local` names need an internal CA such as AD CS.
- **AD CS Enterprise Root CA**, certificate templates (*Web Server*) and the **Web Enrollment** portal.
- **IIS 10**: sites, HTTPS bindings, *Require SSL* (403.4), and **SNI** for several HTTPS sites on one IP.
- **Certificate name matching**: Common Name vs **Subject Alternative Name**, and why browsers require SAN.
- **DNS**: Host (A) records to publish friendly internal service names.
