#!/bin/bash -x
# ================================================================
# VIREBENT.ART - UNIFIED IPTABLES FIREWALL WITH BOT BLOCKING
# Advanced DDoS protection + Commercial crawler blocking
# ================================================================

LOCAL=x.x.x.x/32

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
fi

IPT=/usr/sbin/iptables
IP6TABLES=/usr/sbin/ip6tables

# Check if ipset is available
IPSET_AVAILABLE=0
if command -v ipset >/dev/null 2>&1; then
    IPSET_AVAILABLE=1
    echo "ipset detected - using optimized IP range blocking"
else
    echo "ipset not found - using individual IP rules (less efficient)"
fi

# ================================================================
# RESET ALL RULES
# ================================================================

$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -t raw -F
$IPT -t raw -X

# ================================================================
# SETUP IPSET FOR BOT BLOCKING (if available)
# ================================================================

if [ $IPSET_AVAILABLE -eq 1 ]; then
    echo "Setting up ipset for commercial bot blocking..."
    
    # Destroy existing sets
    ipset destroy google-crawlers 2>/dev/null || true
    ipset destroy bing-crawlers 2>/dev/null || true
    ipset destroy facebook-crawlers 2>/dev/null || true
    ipset destroy malicious-bots 2>/dev/null || true
    
    # Create new sets
    ipset create google-crawlers hash:net family inet maxelem 1000000
    ipset create bing-crawlers hash:net family inet maxelem 1000000
    ipset create facebook-crawlers hash:net family inet maxelem 1000000
    ipset create malicious-bots hash:ip family inet maxelem 1000000
    
    ### Google/Alphabet IP Ranges (Updated Feb 2025) ###
    ipset add google-crawlers 8.8.8.0/24
    ipset add google-crawlers 8.8.4.0/24
    ipset add google-crawlers 8.34.208.0/20
    ipset add google-crawlers 8.35.192.0/20
    ipset add google-crawlers 23.236.48.0/20
    ipset add google-crawlers 23.251.128.0/19
    ipset add google-crawlers 34.0.0.0/9
    ipset add google-crawlers 34.128.0.0/10
    ipset add google-crawlers 35.184.0.0/13
    ipset add google-crawlers 35.192.0.0/14
    ipset add google-crawlers 35.196.0.0/15
    ipset add google-crawlers 35.198.0.0/16
    ipset add google-crawlers 35.199.0.0/17
    ipset add google-crawlers 35.199.128.0/18
    ipset add google-crawlers 35.200.0.0/13
    ipset add google-crawlers 35.208.0.0/12
    ipset add google-crawlers 35.224.0.0/12
    ipset add google-crawlers 35.240.0.0/13
    ipset add google-crawlers 64.233.160.0/19
    ipset add google-crawlers 66.102.0.0/20
    ipset add google-crawlers 66.249.80.0/20
    ipset add google-crawlers 70.32.128.0/19
    ipset add google-crawlers 72.14.192.0/18
    ipset add google-crawlers 74.125.0.0/16
    ipset add google-crawlers 108.177.8.0/21
    ipset add google-crawlers 108.177.96.0/19
    ipset add google-crawlers 130.211.0.0/22
    ipset add google-crawlers 142.250.0.0/15
    ipset add google-crawlers 142.251.0.0/16
    ipset add google-crawlers 172.217.0.0/16
    ipset add google-crawlers 172.253.0.0/16
    ipset add google-crawlers 173.194.0.0/16
    ipset add google-crawlers 192.178.0.0/15
    ipset add google-crawlers 192.178.5.0/27
    ipset add google-crawlers 192.178.6.0/27
    ipset add google-crawlers 192.178.6.32/27
    ipset add google-crawlers 199.36.154.0/23
    ipset add google-crawlers 199.36.156.0/24
    ipset add google-crawlers 208.65.152.0/22
    ipset add google-crawlers 208.68.108.0/22
    ipset add google-crawlers 209.85.128.0/17
    ipset add google-crawlers 216.58.192.0/19
    ipset add google-crawlers 216.239.32.0/19
    
    ### Microsoft/Bing IP Ranges ###
    ipset add bing-crawlers 13.64.0.0/11
    ipset add bing-crawlers 13.96.0.0/13
    ipset add bing-crawlers 13.104.0.0/14
    ipset add bing-crawlers 20.0.0.0/8
    ipset add bing-crawlers 20.15.133.160/27
    ipset add bing-crawlers 23.96.0.0/13
    ipset add bing-crawlers 40.64.0.0/10
    ipset add bing-crawlers 52.96.0.0/12
    ipset add bing-crawlers 52.112.0.0/14
    ipset add bing-crawlers 52.120.0.0/14
    ipset add bing-crawlers 52.125.0.0/16
    ipset add bing-crawlers 65.52.0.0/14
    ipset add bing-crawlers 70.37.0.0/17
    ipset add bing-crawlers 94.245.64.0/18
    ipset add bing-crawlers 131.253.1.0/24
    ipset add bing-crawlers 131.253.3.0/24
    ipset add bing-crawlers 131.253.5.0/24
    ipset add bing-crawlers 131.253.6.0/24
    ipset add bing-crawlers 131.253.8.0/24
    ipset add bing-crawlers 131.253.12.0/22
    ipset add bing-crawlers 131.253.16.0/23
    ipset add bing-crawlers 131.253.18.0/24
    ipset add bing-crawlers 131.253.21.0/24
    ipset add bing-crawlers 131.253.22.0/23
    ipset add bing-crawlers 131.253.24.0/21
    ipset add bing-crawlers 131.253.32.0/20
    ipset add bing-crawlers 131.253.61.0/24
    ipset add bing-crawlers 131.253.62.0/23
    ipset add bing-crawlers 131.253.64.0/18
    ipset add bing-crawlers 131.253.128.0/17
    ipset add bing-crawlers 134.170.0.0/16
    ipset add bing-crawlers 157.54.0.0/15
    ipset add bing-crawlers 157.56.0.0/14
    ipset add bing-crawlers 168.61.0.0/16
    ipset add bing-crawlers 168.62.0.0/15
    ipset add bing-crawlers 191.232.0.0/13
    ipset add bing-crawlers 199.30.16.0/20
    ipset add bing-crawlers 204.79.180.0/24
    ipset add bing-crawlers 207.46.0.0/16
    ipset add bing-crawlers 207.68.128.0/18
    
    ### Facebook/Meta IP Ranges (AS32934) ###
    ipset add facebook-crawlers 31.13.24.0/21
    ipset add facebook-crawlers 31.13.64.0/18
    ipset add facebook-crawlers 31.13.64.0/19
    ipset add facebook-crawlers 31.13.96.0/19
    ipset add facebook-crawlers 45.64.40.0/22
    ipset add facebook-crawlers 66.220.144.0/20
    ipset add facebook-crawlers 66.220.152.0/21
    ipset add facebook-crawlers 69.63.176.0/20
    ipset add facebook-crawlers 69.171.224.0/19
    ipset add facebook-crawlers 69.171.224.0/20
    ipset add facebook-crawlers 69.171.239.0/24
    ipset add facebook-crawlers 69.171.240.0/20
    ipset add facebook-crawlers 69.171.255.0/24
    ipset add facebook-crawlers 74.119.76.0/22
    ipset add facebook-crawlers 103.4.96.0/22
    ipset add facebook-crawlers 129.134.0.0/17
    ipset add facebook-crawlers 157.240.0.0/17
    ipset add facebook-crawlers 173.252.64.0/18
    ipset add facebook-crawlers 173.252.64.0/19
    ipset add facebook-crawlers 173.252.70.0/24
    ipset add facebook-crawlers 173.252.74.0/24
    ipset add facebook-crawlers 173.252.96.0/19
    ipset add facebook-crawlers 179.60.192.0/22
    ipset add facebook-crawlers 185.60.216.0/22
    ipset add facebook-crawlers 204.15.20.0/22
    
    echo "ipset configuration completed"
fi

# ================================================================
# DEFAULT POLICIES
# ================================================================

# Default DROP
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# Allow unlimited traffic on loopback
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# ================================================================
# COMMERCIAL BOT BLOCKING RULES
# ================================================================

if [ $IPSET_AVAILABLE -eq 1 ]; then
    ### Block commercial crawlers using ipset ###
    echo "Applying commercial bot blocking rules with ipset..."
    
    # Create custom chain for bot logging
    $IPT -N BLOCK_COMMERCIAL_BOTS 2>/dev/null || true
    $IPT -F BLOCK_COMMERCIAL_BOTS
    
    # Log and drop with specific prefixes
    $IPT -A BLOCK_COMMERCIAL_BOTS -m set --match-set google-crawlers src -j LOG --log-prefix "VIREBENT-BLOCKED-GOOGLE: " --log-level 4
    $IPT -A BLOCK_COMMERCIAL_BOTS -m set --match-set bing-crawlers src -j LOG --log-prefix "VIREBENT-BLOCKED-BING: " --log-level 4
    $IPT -A BLOCK_COMMERCIAL_BOTS -m set --match-set facebook-crawlers src -j LOG --log-prefix "VIREBENT-BLOCKED-FACEBOOK: " --log-level 4
    $IPT -A BLOCK_COMMERCIAL_BOTS -j DROP
    
    # Apply blocking rules to web traffic
    $IPT -I INPUT 1 -p tcp --dport 80 -m set --match-set google-crawlers src -j BLOCK_COMMERCIAL_BOTS
    $IPT -I INPUT 1 -p tcp --dport 443 -m set --match-set google-crawlers src -j BLOCK_COMMERCIAL_BOTS
    $IPT -I INPUT 1 -p tcp --dport 80 -m set --match-set bing-crawlers src -j BLOCK_COMMERCIAL_BOTS
    $IPT -I INPUT 1 -p tcp --dport 443 -m set --match-set bing-crawlers src -j BLOCK_COMMERCIAL_BOTS
    $IPT -I INPUT 1 -p tcp --dport 80 -m set --match-set facebook-crawlers src -j BLOCK_COMMERCIAL_BOTS
    $IPT -I INPUT 1 -p tcp --dport 443 -m set --match-set facebook-crawlers src -j BLOCK_COMMERCIAL_BOTS
    
    ### Additional protection against AI scrapers ###
    $IPT -A INPUT -p tcp --dport 80 -m string --string "GPTBot" --algo bm -j LOG --log-prefix "VIREBENT-BLOCKED-AI: "
    $IPT -A INPUT -p tcp --dport 80 -m string --string "GPTBot" --algo bm -j DROP
    $IPT -A INPUT -p tcp --dport 443 -m string --string "ChatGPT-User" --algo bm -j LOG --log-prefix "VIREBENT-BLOCKED-AI: "
    $IPT -A INPUT -p tcp --dport 443 -m string --string "ChatGPT-User" --algo bm -j DROP
    
else
    ### Fallback: Block major crawler IPs without ipset ###
    echo "Applying commercial bot blocking rules without ipset (less efficient)..."
    
    # Block major Google crawler ranges
    $IPT -A INPUT -p tcp --dport 80 -s 66.249.80.0/20 -j LOG --log-prefix "VIREBENT-BLOCKED-GOOGLE: "
    $IPT -A INPUT -p tcp --dport 80 -s 66.249.80.0/20 -j DROP
    $IPT -A INPUT -p tcp --dport 443 -s 66.249.80.0/20 -j LOG --log-prefix "VIREBENT-BLOCKED-GOOGLE: "
    $IPT -A INPUT -p tcp --dport 443 -s 66.249.80.0/20 -j DROP
    $IPT -A INPUT -p tcp --dport 80 -s 142.250.0.0/15 -j LOG --log-prefix "VIREBENT-BLOCKED-GOOGLE: "
    $IPT -A INPUT -p tcp --dport 80 -s 142.250.0.0/15 -j DROP
    $IPT -A INPUT -p tcp --dport 443 -s 142.250.0.0/15 -j LOG --log-prefix "VIREBENT-BLOCKED-GOOGLE: "
    $IPT -A INPUT -p tcp --dport 443 -s 142.250.0.0/15 -j DROP
    
    # Block major Bing crawler ranges
    $IPT -A INPUT -p tcp --dport 80 -s 157.55.0.0/16 -j LOG --log-prefix "VIREBENT-BLOCKED-BING: "
    $IPT -A INPUT -p tcp --dport 80 -s 157.55.0.0/16 -j DROP
    $IPT -A INPUT -p tcp --dport 443 -s 157.55.0.0/16 -j LOG --log-prefix "VIREBENT-BLOCKED-BING: "
    $IPT -A INPUT -p tcp --dport 443 -s 157.55.0.0/16 -j DROP
    $IPT -A INPUT -p tcp --dport 80 -s 207.46.0.0/16 -j LOG --log-prefix "VIREBENT-BLOCKED-BING: "
    $IPT -A INPUT -p tcp --dport 80 -s 207.46.0.0/16 -j DROP
    $IPT -A INPUT -p tcp --dport 443 -s 207.46.0.0/16 -j LOG --log-prefix "VIREBENT-BLOCKED-BING: "
    $IPT -A INPUT -p tcp --dport 443 -s 207.46.0.0/16 -j DROP
    
    # Block major Facebook crawler ranges
    $IPT -A INPUT -p tcp --dport 80 -s 69.171.224.0/19 -j LOG --log-prefix "VIREBENT-BLOCKED-FACEBOOK: "
    $IPT -A INPUT -p tcp --dport 80 -s 69.171.224.0/19 -j DROP
    $IPT -A INPUT -p tcp --dport 443 -s 69.171.224.0/19 -j LOG --log-prefix "VIREBENT-BLOCKED-FACEBOOK: "
    $IPT -A INPUT -p tcp --dport 443 -s 69.171.224.0/19 -j DROP
    $IPT -A INPUT -p tcp --dport 80 -s 173.252.64.0/18 -j LOG --log-prefix "VIREBENT-BLOCKED-FACEBOOK: "
    $IPT -A INPUT -p tcp --dport 80 -s 173.252.64.0/18 -j DROP
    $IPT -A INPUT -p tcp --dport 443 -s 173.252.64.0/18 -j LOG --log-prefix "VIREBENT-BLOCKED-FACEBOOK: "
    $IPT -A INPUT -p tcp --dport 443 -s 173.252.64.0/18 -j DROP
fi

# ================================================================
# ANTI DDOS RULES
# ================================================================

### 1: Drop invalid packets ###
$IPT -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

### 2: Drop TCP packets that are new and are not SYN ###
$IPT -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

### 3: Drop SYN packets with suspicious MSS value ###
$IPT -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

### 4: Block packets with bogus TCP flags ###
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
$IPT -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

### 5: Block spoofed packets ###
$IPT -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP
$IPT -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP
$IPT -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP
$IPT -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP
#$IPT -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP
#$IPT -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP
#$IPT -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP
$IPT -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP
#$IPT -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP

### 6: Drop ICMP (you usually don't need this protocol) ###
$IPT -t mangle -A PREROUTING -p icmp -j DROP

### 7: Drop fragments in all chains ###
$IPT -t mangle -A PREROUTING -f -j DROP

# ================================================================
# FORWARD RULES
# ================================================================

$IPT -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT 
$IPT -A FORWARD -s $LOCAL -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

# ================================================================
# CONNECTION LIMITING AND RATE LIMITING
# ================================================================

### 8: Limit connections per source IP ###
$IPT -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset

### 9: Limit RST packets ###
$IPT -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
$IPT -A INPUT -p tcp --tcp-flags RST RST -j DROP

### 10: Enhanced rate limiting for web crawlers ###
$IPT -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -m recent --set --name web_crawlers
$IPT -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 30 --name web_crawlers -j LOG --log-prefix "VIREBENT-CRAWLER-FLOOD: "
$IPT -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 30 --name web_crawlers -j DROP

$IPT -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -m recent --set --name https_crawlers
$IPT -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 30 --name https_crawlers -j LOG --log-prefix "VIREBENT-CRAWLER-FLOOD: "
$IPT -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 30 --name https_crawlers -j DROP

### Protection against port scanning ###
$IPT -N port-scanning
$IPT -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
$IPT -A port-scanning -j DROP

# ================================================================
# SERVICE RULES
# ================================================================

# SMTP/IMAP
$IPT -A INPUT -p tcp -i eth0 -m multiport --dports 25,2525,465,587,143 -j ACCEPT

# HTTP/HTTPS (only after bot blocking rules)
$IPT -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
$IPT -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT

# Allow DNS
$IPT -A INPUT -p tcp -m state --state NEW --sport 53 -j ACCEPT
$IPT -A INPUT -p udp -m state --state NEW --sport 53 -j ACCEPT

### SSH brute-force protection ###
$IPT -I INPUT 1 -p tcp --dport 22222 -m conntrack --ctstate NEW -m recent --set
$IPT -I INPUT 2 -p tcp --dport 22222 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP  
$IPT -I INPUT 3 -p tcp --dport 22222 -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT

# ================================================================
# OUTPUT RULES
# ================================================================

$IPT -A OUTPUT -s $LOCAL -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# ================================================================
# FINAL CLEANUP
# ================================================================

# DROP INVALIDS ALL OVER
$IPT -A INPUT -m state --state INVALID -j DROP
$IPT -A FORWARD -m state --state INVALID -j DROP
$IPT -A OUTPUT -m state --state INVALID -j DROP

# ================================================================
# IPv6 BLOCKING
# ================================================================

# DROP IPv6
# for native IPv6 connections only! -> 6to4: 2002::/16 & Teredo: 2001:0::/32
$IP6TABLES -A INPUT -s 2002::/16 -j DROP
$IP6TABLES -A INPUT -s 2001:0::/32 -j DROP
$IP6TABLES -A FORWARD -s 2002::/16 -j DROP
$IP6TABLES -A FORWARD -s 2001:0::/32 -j DROP

# ================================================================
# SAVE CONFIGURATION AND CREATE MONITORING TOOLS
# ================================================================

if [ $IPSET_AVAILABLE -eq 1 ]; then
    # Save ipset configuration
    ipset save > /etc/ipset.virebent.conf 2>/dev/null || ipset save > /tmp/ipset.virebent.conf
fi

# Save iptables rules
iptables-save > /etc/iptables.virebent.rules 2>/dev/null || iptables-save > /tmp/iptables.virebent.rules

# Create monitoring script
cat > /usr/local/bin/virebent-monitor.sh << 'EOF'
#!/bin/bash
echo "=== VIREBENT FIREWALL STATUS ==="
echo "Blocked bots in last hour:"
journalctl --since "1 hour ago" | grep "VIREBENT-BLOCKED" | wc -l

echo ""
echo "Recent blocks by type:"
journalctl --since "1 hour ago" | grep "VIREBENT-BLOCKED-GOOGLE" | wc -l | xargs echo "Google:"
journalctl --since "1 hour ago" | grep "VIREBENT-BLOCKED-BING" | wc -l | xargs echo "Bing:"
journalctl --since "1 hour ago" | grep "VIREBENT-BLOCKED-FACEBOOK" | wc -l | xargs echo "Facebook:"

echo ""
echo "Active connections:"
ss -tuln | grep -E ":80|:443|:22222"

if command -v ipset >/dev/null 2>&1; then
    echo ""
    echo "ipset statistics:"
    echo "Google ranges: $(ipset list google-crawlers 2>/dev/null | grep -c '^[0-9]' || echo 'N/A')"
    echo "Bing ranges: $(ipset list bing-crawlers 2>/dev/null | grep -c '^[0-9]' || echo 'N/A')"
    echo "Facebook ranges: $(ipset list facebook-crawlers 2>/dev/null | grep -c '^[0-9]' || echo 'N/A')"
fi
EOF

chmod +x /usr/local/bin/virebent-monitor.sh

echo ""
echo "================================================================"
echo "✅ VIREBENT FIREWALL APPLIED SUCCESSFULLY"
echo "================================================================"
echo ""
echo "📊 Configuration summary:"
echo "   - Anti-DDoS protection: ENABLED"
echo "   - Commercial bot blocking: ENABLED"
if [ $IPSET_AVAILABLE -eq 1 ]; then
    echo "   - ipset optimization: ENABLED"
    echo "   - Google ranges blocked: $(ipset list google-crawlers | grep -c '^[0-9]')"
    echo "   - Bing ranges blocked: $(ipset list bing-crawlers | grep -c '^[0-9]')"
    echo "   - Facebook ranges blocked: $(ipset list facebook-crawlers | grep -c '^[0-9]')"
else
    echo "   - ipset optimization: DISABLED (install ipset for better performance)"
fi
echo ""
echo "📋 Monitoring commands:"
echo "   # Real-time bot blocking"
echo "   tail -f /var/log/syslog | grep 'VIREBENT-BLOCKED'"
echo ""
echo "   # Firewall status"
echo "   /usr/local/bin/virebent-monitor.sh"
echo ""
echo "   # View blocked ranges"
if [ $IPSET_AVAILABLE -eq 1 ]; then
    echo "   ipset list google-crawlers"
fi
echo ""
echo "🔧 Configuration files:"
if [ $IPSET_AVAILABLE -eq 1 ]; then
    echo "   ipset: /etc/ipset.virebent.conf (or /tmp/ipset.virebent.conf)"
fi
echo "   iptables: /etc/iptables.virebent.rules (or /tmp/iptables.virebent.rules)"
echo ""
echo "================================================================"
