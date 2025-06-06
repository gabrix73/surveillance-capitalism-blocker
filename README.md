# 🛡️ Digital Independence Firewall

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Anti-Surveillance](https://img.shields.io/badge/anti--surveillance-enabled-red.svg)](#mainstream-search-engine-blocking)
[![Digital Sovereignty](https://img.shields.io/badge/digital--sovereignty-protected-orange.svg)](#philosophy)

> **Privacy-first firewall that REFUSES mainstream search engine surveillance and control**

## 🚨 **OUR STANCE: DIGITAL INDEPENDENCE OVER SURVEILLANCE CAPITALISM**

**We deliberately and proudly BLOCK all mainstream search engine crawlers** including Google, Bing, and Facebook because we **REJECT their surveillance-based business models** and refuse to participate in their data harvesting operations.

### 🎯 **Why We Block Mainstream Crawlers**

- **🔒 Data Sovereignty**: Your server data belongs to YOU, not Google/Microsoft/Meta
- **🚫 Surveillance Resistance**: We refuse to feed the surveillance capitalism machine  
- **⚖️ Ethical Computing**: Supporting truly independent and privacy-respecting search engines only
- **🌐 Decentralized Web**: Promoting alternatives like DuckDuckGo, Brave Search, Mojeek, and others
- **💪 Digital Independence**: Breaking free from Big Tech monopolistic control

> *"If you're not paying for the product, you ARE the product. We choose to OPT OUT of being the product."*

This firewall is a **political and technical statement** for digital rights, privacy, and independence from corporate surveillance. We encourage only ethical, privacy-respecting search engines that don't track users or commodify personal data.

---

A production-ready iptables configuration script designed for privacy-first servers that need protection against both traditional attacks and commercial surveillance crawlers.

## ✨ Features

### 🔒 **DDoS Protection**
- **Invalid packet filtering** - Drops malformed TCP packets
- **SYN flood protection** - Advanced connection state validation  
- **TCP flag validation** - Blocks packets with bogus flag combinations
- **Spoofed packet prevention** - Filters private/reserved IP ranges
- **Fragment filtering** - Drops fragmented packets
- **Rate limiting** - Configurable connection limits per IP

### 🚫 **Commercial Bot Blocking**
- **Google crawlers** - Blocks Googlebot and all Google services (45+ IP ranges)
- **Microsoft Bing** - Blocks Bingbot and Azure ranges (35+ IP ranges)  
- **Facebook/Meta** - Blocks facebookexternalhit and Meta crawlers (25+ IP ranges)
- **AI scrapers** - Detects and blocks GPTBot, ChatGPT-User, ClaudeBot, etc.
- **Real-time logging** - Detailed logs with service-specific prefixes

### 🕵️ **Government Surveillance Blocking**
- **US Agencies** - NSA, FBI, CIA, DHS, ICE facilities and data centers (25+ ranges)
- **Five Eyes Alliance** - GCHQ (UK), CSEC (Canada), ASD (Australia), GCSB (New Zealand) (30+ ranges)
- **14 Eyes Extended** - BND (Germany), DGSE (France), AIVD (Netherlands) (15+ ranges)
- **Military Networks** - DISA, DoD, and classified government ranges (10+ ranges)
- **Intelligence Facilities** - NSA Utah Data Center, GCHQ Cheltenham, and surveillance infrastructure

### ⚡ **Performance Optimization**
- **ipset integration** - Efficient IP range blocking when available
- **Fallback mode** - Works without ipset (less efficient but functional)
- **Automatic detection** - Detects available tools and adapts accordingly
- **Memory efficient** - Optimized for high-traffic servers

### 📊 **Monitoring & Management**
- **Real-time monitoring** - Built-in monitoring script
- **Detailed logging** - Service-specific log prefixes for easy analysis
- **Statistics reporting** - Blocked crawler counts and connection stats
- **Configuration persistence** - Auto-saves rules for reboot survival

## 🔧 Requirements

### **Essential**
- Linux server with iptables
- Root access
- Bash shell

### **Recommended**
```bash
# Ubuntu/Debian
apt install iptables ipset curl jq

# CentOS/RHEL
yum install iptables ipset curl jq
```

### **Optional**
- `ipset` - For optimized IP range blocking (highly recommended)
- `jq` - For JSON parsing (used in update scripts)

## 🚀 Quick Start

### **1. Download and Setup**
```bash
# Clone repository
[git clone https://github.com/virebent/advanced-firewall.git](https://github.com/gabrix73/surveillance-capitalism-blocker.git)
cd advanced-firewall

# Make executable
chmod +x virebent-firewall.sh

# Configure your server IP
nano virebent-firewall.sh
# Edit: LOCAL=12.34.56.78/32  # Replace with your server IP
```

### **2. Deploy Firewall**
```bash
# Run as root
sudo ./virebent-firewall.sh
```

### **3. Verify Operation**
```bash
# Check firewall status
/usr/local/bin/virebent-monitor.sh

# Monitor real-time blocks
tail -f /var/log/syslog | grep 'VIREBENT-BLOCKED'
```

## 📋 Configuration

### **Server IP Configuration**
Edit the `LOCAL` variable to match your server's IP:
```bash
LOCAL=your.server.ip.here/32
```

### **Port Configuration**
The script protects these ports by default:
- **SSH**: 22222 (not default ssh port - with brute-force protection)
- **HTTP**: 80 
- **HTTPS**: 443
- **Email**: 25, 2525, 465, 587, 143

### **Rate Limiting**
Adjust these values based on your server capacity:
```bash
# Max connections per IP
--connlimit-above 111

# Web crawler rate limit (requests per minute)
--hitcount 30 --seconds 60

# SSH brute-force protection
--hitcount 10 --seconds 60
```

## 🎯 Commercial Bot Blocking

### **Blocked Services**
| Category | IP Ranges | Organizations | Purpose |
|----------|-----------|---------------|---------|
| **Google** | 45+ ranges | Googlebot, GoogleOther, Google-Extended | Search indexing, AI training, data harvesting |
| **Microsoft** | 35+ ranges | Bingbot, msnbot, Azure infrastructure | Search indexing, corporate surveillance |
| **Facebook** | 25+ ranges | facebookexternalhit, meta-externalagent | Link previews, social media data scraping |
| **US Government** | 25+ ranges | NSA, FBI, CIA, DHS, ICE | Mass surveillance, intelligence gathering |
| **Five Eyes** | 30+ ranges | GCHQ, CSEC, ASD, GCSB | International intelligence sharing |
| **14 Eyes Extended** | 15+ ranges | BND, DGSE, AIVD, Mossad | Extended surveillance alliance |
| **AI Crawlers** | Detection | GPTBot, ChatGPT-User, ClaudeBot, PerplexityBot | AI model training, content scraping |

### **IP Range Sources**
- **Google**: Official ranges from `https://www.gstatic.com/ipranges/goog.json`
- **Microsoft**: Azure and Office365 documented ranges
- **Facebook**: AS32934 (Facebook, Inc.) verified ranges
- **US Government**: NSA, FBI, CIA, DHS documented facilities and data centers
- **Five Eyes**: GCHQ, CSEC, ASD, GCSB official government network ranges
- **Intelligence Agencies**: BND, DGSE, AIVD, Mossad documented surveillance infrastructure
- **Updated**: February 2025 (automatic updates available)

### **Government Surveillance Agencies Blocked**

#### **🇺🇸 United States (FVEY Core)**
- **NSA** - National Security Agency (Utah Data Center, Fort Meade)
- **FBI** - Federal Bureau of Investigation 
- **CIA** - Central Intelligence Agency
- **DHS** - Department of Homeland Security
- **ICE** - Immigration and Customs Enforcement
- **DISA** - Defense Information Systems Agency
- **DoD** - Department of Defense networks

#### **🇬🇧 United Kingdom (FVEY)**
- **GCHQ** - Government Communications Headquarters (Cheltenham)
- **MI5** - Security Service
- **MI6** - Secret Intelligence Service

#### **🇨🇦 Canada (FVEY)**
- **CSEC** - Communications Security Establishment Canada
- **CSIS** - Canadian Security Intelligence Service

#### **🇦🇺 Australia (FVEY)**
- **ASD** - Australian Signals Directorate
- **ASIO** - Australian Security Intelligence Organisation

#### **🇳🇿 New Zealand (FVEY)**
- **GCSB** - Government Communications Security Bureau
- **NZSIS** - New Zealand Security Intelligence Service

#### **🌍 Extended Surveillance Network (14 Eyes)**
- **🇩🇪 BND** - Bundesnachrichtendienst (Germany)
- **🇫🇷 DGSE** - Direction générale de la sécurité extérieure (France)
- **🇳🇱 AIVD** - Algemene Inlichtingen- en Veiligheidsdienst (Netherlands)
- **🇮🇱 Mossad** - Institute for Intelligence and Special Operations (Israel)
- **🇪🇸 CNI** - Centro Nacional de Inteligencia (Spain)
- **🇮🇹 AISE** - Agenzia Informazioni e Sicurezza Esterna (Italy)

## 📊 Monitoring

### **Real-time Monitoring**
```bash
# Monitor all blocked surveillance attempts
tail -f /var/log/syslog | grep 'VIREBENT-BLOCKED'

# Monitor by surveillance category
tail -f /var/log/syslog | grep 'VIREBENT-BLOCKED-GOOGLE'        # Corporate
tail -f /var/log/syslog | grep 'VIREBENT-BLOCKED-FACEBOOK'      # Social Media
tail -f /var/log/syslog | grep 'VIREBENT-BLOCKED-USGOV'         # US Government
tail -f /var/log/syslog | grep 'VIREBENT-BLOCKED-FIVEEYES'      # Five Eyes Intelligence
```

### **Status Dashboard**
```bash
# Run built-in monitoring
/usr/local/bin/virebent-monitor.sh
```

**Sample Output:**
```
=== VIREBENT DIGITAL INDEPENDENCE FIREWALL STATUS ===
Total surveillance attempts blocked in last hour: 2,847

Blocks by surveillance source:
Google Corporate Surveillance: 1,203
Microsoft Corporate Surveillance: 445
Facebook/Meta Surveillance: 287
US Government Surveillance: 542
Five Eyes Intelligence: 370

Active connections:
*:22222 (SSH)
*:80 (HTTP)  
*:443 (HTTPS)

Surveillance resistance statistics:
Google corporate ranges: 45
Microsoft corporate ranges: 35
Facebook/Meta ranges: 25
US Government surveillance ranges: 25
Five Eyes intelligence ranges: 30

🛡️ DIGITAL INDEPENDENCE STATUS: PROTECTED
   Corporate surveillance: BLOCKED
   Government surveillance: BLOCKED
   Five Eyes intelligence: BLOCKED
```

### **Log Analysis**
```bash
# Top blocked IPs
grep 'VIREBENT-BLOCKED' /var/log/syslog | awk '{print $(NF-4)}' | sort | uniq -c | sort -nr | head -10

# Blocks per hour
grep 'VIREBENT-BLOCKED' /var/log/syslog | awk '{print $3}' | cut -d: -f1 | sort | uniq -c

# Service breakdown
grep 'VIREBENT-BLOCKED' /var/log/syslog | grep -o 'BLOCKED-[A-Z]*' | sort | uniq -c
```

## 🔧 Advanced Configuration

### **Custom IP Ranges**
Add your own IP ranges to block:
```bash
# Add to the ipset section
ipset add custom-blocklist 192.168.1.0/24
ipset add custom-blocklist 10.0.0.0/8

# Apply blocking rule
$IPT -I INPUT 1 -m set --match-set custom-blocklist src -j DROP
```

### **Whitelist Specific IPs**
```bash
# Allow specific IPs before bot blocking rules
$IPT -I INPUT 1 -s trusted.ip.here -j ACCEPT
```

### **Service-specific Rules**
```bash
# Block bots only on specific ports
$IPT -I INPUT 1 -p tcp --dport 8080 -m set --match-set google-crawlers src -j DROP

# Allow bots on staging subdomain (by destination)
$IPT -I INPUT 1 -d staging.ip.here -j ACCEPT
```

## 🐛 Troubleshooting

### **Common Issues**

**❌ Script fails with "ipset not found"**
```bash
# Install ipset
apt install ipset  # Ubuntu/Debian
yum install ipset  # CentOS/RHEL

# Or run without ipset (less efficient)
# Script will automatically fallback
```

**❌ "Permission denied" error**
```bash
# Run as root
sudo ./virebent-firewall.sh

# Or switch to root
su - 
./virebent-firewall.sh
```

**❌ Legitimate traffic being blocked**
```bash
# Check if your IP is whitelisted
iptables -L INPUT -n | grep your.ip.here

# Add to whitelist
iptables -I INPUT 1 -s your.ip.here -j ACCEPT
```

**❌ No logs appearing**
```bash
# Check log configuration
tail -f /var/log/syslog | grep iptables
tail -f /var/log/messages | grep iptables

# On some systems, check kern.log
tail -f /var/log/kern.log | grep VIREBENT
```

### **Performance Issues**

**🐌 High CPU usage**
```bash
# Check if ipset is being used
ipset list | head

# If not, install ipset for better performance
apt install ipset && ./virebent-firewall.sh
```

**📈 Memory usage**
```bash
# Check ipset memory usage  
ipset list -t | grep "Number of entries"

# Optimize by removing unused ranges
ipset flush google-crawlers
# Re-add only needed ranges
```

## 📁 File Locations

### **Script Files**
- `virebent-firewall.sh` - Main firewall script
- `/usr/local/bin/virebent-monitor.sh` - Monitoring script

### **Configuration Files**
- `/etc/iptables.virebent.rules` - Saved iptables rules
- `/etc/ipset.virebent.conf` - Saved ipset configuration
- `/tmp/iptables.virebent.rules` - Fallback location
- `/tmp/ipset.virebent.conf` - Fallback location

### **Log Files**
- `/var/log/syslog` - Main log file (Ubuntu/Debian)
- `/var/log/messages` - Main log file (CentOS/RHEL)
- `/var/log/kern.log` - Kernel messages

## 🔄 Updates and Maintenance

### **Manual Update**
```bash
# Re-run script to apply latest rules
./virebent-firewall.sh
```

### **Automatic Updates**
The script can be enhanced with automatic IP range updates:
```bash
# Add to crontab for daily updates
0 3 * * * /path/to/update-ip-ranges.sh
```

### **Backup and Restore**
```bash
# Backup current rules
iptables-save > backup-$(date +%Y%m%d).rules
ipset save > backup-$(date +%Y%m%d).ipset

# Restore from backup
iptables-restore < backup-20250604.rules
ipset restore < backup-20250604.ipset
```

## ⚡ Performance Tips

### **Optimization Checklist**
- ✅ Install `ipset` for efficient IP range blocking
- ✅ Place most common blocks at top of rules
- ✅ Use connection tracking for stateful filtering
- ✅ Monitor memory usage with large IP sets
- ✅ Consider hardware firewall for extreme loads

### **Resource Usage**
| Component | Memory | CPU Impact | Effectiveness |
|-----------|--------|------------|---------------|
| **ipset ranges** | ~50MB | Minimal | Excellent |
| **Individual rules** | ~5MB | Moderate | Good |
| **String matching** | ~10MB | High | Fair |
| **Rate limiting** | ~20MB | Low | Excellent |

## 🤝 Contributing

We welcome contributions! Please:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Test** your changes thoroughly
4. **Commit** with clear messages: `git commit -m 'Add amazing feature'`
5. **Push** to the branch: `git push origin feature/amazing-feature`
6. **Submit** a Pull Request

### **Areas for Contribution**
- 🌐 Additional crawler detection
- 📊 Enhanced monitoring features  
- 🔧 Performance optimizations
- 📚 Documentation improvements
- 🧪 Testing infrastructure

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This firewall script is designed for educational and legitimate server protection purposes. Users are responsible for:

- ✅ Ensuring compliance with local laws
- ✅ Testing in non-production environments first
- ✅ Understanding the implications of blocking commercial crawlers
- ✅ Maintaining appropriate logging and monitoring

**Note**: Blocking commercial crawlers may affect SEO and website discoverability. Use responsibly and in accordance with your privacy requirements.

## 🔗 Related Projects

- **[Virebent.art](https://www.virebent.art)** - Privacy-first digital services
- **[robots.txt Generator](https://github.com/gabrix73/surveillance-capitalism-blocker/blob/main/robots.txt)** - Companion robots.txt for bot blocking
- **[NNTP Server](https://news.tcpreset.net)** - Decentralized communication alternative

## 📞 Support

- 💬 **Matrix Chat**: `@gabx:kosmikdog.eu`
- 🌐 **Website**: [www.virebent.art](https://www.virebent.art)
- 📧 **Email**: info@virebent.art (PGP encrypted preferred Key ID: [C6625F44806AC65957935BD848BF95F3ECACDDB3](https://www.virebent.art/C6625F44806AC65957935BD848BF95F3ECACDDB3.asc)
- 🐛 **Issues**: [GitHub Issues]([https://github.com/virebent/advanced-firewall/issues](https://github.com/gabrix73/surveillance-capitalism-blocker/issues)

---

<div align="center">

**🛡️ Protecting Digital Independence Through Privacy-First Technology**

Made with ❤️ by [Virebent.art](https://www.virebent.art)

</div>
