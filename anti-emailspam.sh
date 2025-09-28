#!/bin/bash
# =================================================================================
# Script Firewall Avanzato con Blocco Proattivo per Server di Posta
# Versione Migliorata con ipset e protezioni aggiuntive
# Per Ubuntu 24 / iptables-nft
# =================================================================================

# --- VARIABILI DI CONFIGURAZIONE ---
IPT=/usr/sbin/iptables
IP6T=/usr/sbin/ip6tables
IPSET=/usr/sbin/ipset

# Nomi dei set per ipset (devono corrispondere a quelli creati dallo script di aggiornamento)
BLACKLIST_SET="blacklist"

# Altre variabili
SSH_PORT="22222"
MAIL_PORTS="25,143,465,587,993" # Aggiunto IMAPS (993)
WEB_PORTS="80,443"

# --- 0. VERIFICHE INIZIALI ---
if ! command -v $IPSET &> /dev/null; then
    echo "ipset non è installato. Esegui: sudo apt update && sudo apt install ipset"
    exit 1
fi
if [[ $EUID -ne 0 ]]; then
   echo "Questo script deve essere eseguito come root" 1>&2
   exit 1
fi

echo "Inizio configurazione firewall avanzato..."

# --- 1. RESET INIZIALE SICURO ---
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -F; $IPT -X; $IPT -t nat -F; $IPT -t nat -X; $IPT -t mangle -F; $IPT -t mangle -X

# --- 2. CREAZIONE DEI SET IPSET (se non esistono) ---
# Verranno popolati dallo script di aggiornamento, ma li creiamo qui per evitare errori.
$IPSET create $BLACKLIST_SET hash:net family inet -exist

# --- 3. IMPOSTAZIONE POLICY RESTRITTIVE ---
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT # Policy più permissiva in uscita per semplicità (aggiornamenti, DNS, etc.)

# --- 4. CREAZIONE CATENE PERSONALIZZATE ---
$IPT -N TCP_CHAIN
$IPT -N UDP_CHAIN
$IPT -N MAIL_SECURITY_CHAIN
$IPT -N GENERAL_PROTECTION # NUOVA catena per le protezioni globali
$IPT -N LOG_AND_DROP # NUOVA catena per logging specifico

# --- 5. REGOLE GLOBALI DI BASE ---
# Loopback
$IPT -A INPUT -i lo -j ACCEPT
# Connessioni già stabilite (fondamentale)
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Drop pacchetti invalidi
$IPT -A INPUT -m conntrack --ctstate INVALID -j DROP

# --- 6. BLOCCO PROATTIVO CON IPSET (LA NOVITÀ PIÙ IMPORTANTE) ---
# Controlla TUTTO il nuovo traffico in entrata contro la nostra blocklist.
$IPT -A INPUT -m set --match-set $BLACKLIST_SET src -j LOG_AND_DROP

# --- 7. INDIRIZZAMENTO ALLE CATENE SPECIFICHE ---
# Manda il traffico alla catena di protezione generale PRIMA di gestirlo.
$IPT -A INPUT -p tcp --syn -j GENERAL_PROTECTION
# Indirizza il traffico nuovo (non bloccato) alle catene per protocollo.
$IPT -A INPUT -p udp -m conntrack --ctstate NEW -j UDP_CHAIN
$IPT -A INPUT -p tcp -m conntrack --ctstate NEW -j TCP_CHAIN

# --- 8. CATENA DI PROTEZIONE GENERALE ---
# Blocco pacchetti malformati (usati per scansioni)
$IPT -A GENERAL_PROTECTION -p tcp --tcp-flags ALL ALL -j LOG_AND_DROP
$IPT -A GENERAL_PROTECTION -p tcp --tcp-flags ALL NONE -j LOG_AND_DROP

# Protezione base da SYN Flood
$IPT -A GENERAL_PROTECTION -p tcp --syn -m limit --limit 10/s --limit-burst 20 -j RETURN

# Protezione da Ping Flood (ICMP)
$IPT -A INPUT -p icmp --icmp-type 8 -m limit --limit 1/s --limit-burst 2 -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 8 -j DROP
$IPT -A INPUT -p icmp -j ACCEPT # Permetti altri ICMP essenziali

# --- 9. REGOLE PER SERVIZI SPECIFICI (TCP) ---
# SSH (con protezione brute-force migliorata)
$IPT -A TCP_CHAIN -p tcp --dport $SSH_PORT -m conntrack --ctstate NEW -m recent --set --name SSH
$IPT -A TCP_CHAIN -p tcp --dport $SSH_PORT -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 --name SSH -j LOG_AND_DROP
$IPT -A TCP_CHAIN -p tcp --dport $SSH_PORT -j ACCEPT

# WEB (HTTP/HTTPS)
$IPT -A TCP_CHAIN -p tcp -m multiport --dports $WEB_PORTS -j ACCEPT

# POSTA (collegamento alla catena di sicurezza avanzata)
$IPT -A TCP_CHAIN -p tcp -m multiport --dports $MAIL_PORTS -j MAIL_SECURITY_CHAIN

# --- 10. CATENA DI SICUREZZA AVANZATA PER LA POSTA ---
# Mitigazione Flood/Scan (blocca chi fa più di 10 connessioni in 120s)
$IPT -A MAIL_SECURITY_CHAIN -m recent --set --name MAIL_SCANNER
$IPT -A MAIL_SECURITY_CHAIN -m recent --update --seconds 120 --hitcount 10 --name MAIL_SCANNER -j LOG_AND_DROP

# Limita connessioni simultanee (massimo 20 per IP)
$IPT -A MAIL_SECURITY_CHAIN -p tcp -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

# Se tutti i controlli passano, accetta la connessione
$IPT -A MAIL_SECURITY_CHAIN -j ACCEPT

# --- 11. CATENA DI LOG E DROP ---
$IPT -A LOG_AND_DROP -j LOG --log-prefix "BLACKLISTED_DROP: " --log-level 4
$IPT -A LOG_AND_DROP -j DROP

# --- 12. BLOCCO IPv6 (se non lo usi) ---
# (Script originale era già corretto)
$IP6T -P INPUT DROP; $IP6T -P FORWARD DROP; $IP6T -P OUTPUT ACCEPT
$IP6T -A INPUT -i lo -j ACCEPT
$IP6T -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "✅ Firewall configurato con successo!"
