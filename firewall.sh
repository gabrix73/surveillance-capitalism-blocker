#!/bin/bash
# ==========================================================================
# Script Firewall Avanzato per Server di Posta (Ubuntu 24 / iptables-nft)
# ==========================================================================

# --- VARIABILI DI CONFIGURAZIONE ---
IPT=/usr/sbin/iptables
IP6T=/usr/sbin/ip6tables

SERVER_IP="159.69.152.35" # Il tuo IP pubblico
SSH_PORT="22222"
MAIL_PORTS="25,143,465,587" # Porte Mail (IMAP, SMTP, Submission)
WEB_PORTS="80,443"

# Verifica di essere root
if [[ $EUID -ne 0 ]]; then
   echo "Questo script deve essere eseguito come root" 1>&2
   exit 1
fi

echo "Inizio configurazione firewall..."

# --- 1. RESET INIZIALE SICURO ---
# Imposta le policy predefinite su ACCEPT per evitare di bloccarsi fuori durante il flush.
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT

# Flush di tutte le regole e catene esistenti
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -t raw -F
$IPT -t raw -X

# Imposta le policy predefinite restrittive: blocca tutto ciò che non è esplicitamente permesso.
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT DROP


# --- 2. REGOLE GLOBALI DI BASE ---

# Permetti tutto il traffico sull'interfaccia di loopback (essenziale per il funzionamento del sistema)
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# Permetti le connessioni in USCITA che sono già state stabilite o correlate.
# Questo permette al server di ricevere risposte al traffico che ha iniziato (es. query DNS, aggiornamenti APT).
$IPT -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permetti le connessioni in ENTRATA che sono parte di sessioni già stabilite.
# Questa è la regola più importante per le performance e la logica stateful.
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Drop dei pacchetti "invalidi" che non dovrebbero esistere.
$IPT -A INPUT -m conntrack --ctstate INVALID -j DROP


# --- 3. REGOLE ANTI-ATTACCO (Meno aggressive, più efficaci) ---

# Protezione da SYN Flood base
$IPT -A INPUT -p tcp --syn -m limit --limit 10/s --limit-burst 20 -j ACCEPT
$IPT -A INPUT -p tcp --syn -j DROP

# Protezione da Ping Flood (ICMP Echo Request)
# NON bloccare tutto ICMP! È vitale per la salute della rete (es. MTU Discovery).
$IPT -A INPUT -p icmp --icmp-type 8 -m limit --limit 1/s --limit-burst 2 -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 8 -j DROP
# Permetti altri tipi di ICMP essenziali
$IPT -A INPUT -p icmp --icmp-type 0 -j ACCEPT # Echo Reply
$IPT -A INPUT -p icmp --icmp-type 3 -j ACCEPT # Destination Unreachable

# --- 4. CREAZIONE CATENE PERSONALIZZATE (Per una maggiore leggibilità) ---
$IPT -N TCP_CHAIN
$IPT -N UDP_CHAIN
$IPT -N MAIL_SECURITY_CHAIN

# Indirizza il traffico nuovo alle catene appropriate
$IPT -A INPUT -p udp -m conntrack --ctstate NEW -j UDP_CHAIN
$IPT -A INPUT -p tcp -m conntrack --ctstate NEW -j TCP_CHAIN


# --- 5. REGOLE PER SERVIZI SPECIFICI (TCP) ---

# SSH (con protezione brute-force)
$IPT -A TCP_CHAIN -p tcp --dport $SSH_PORT -m recent --set --name SSH
$IPT -A TCP_CHAIN -p tcp --dport $SSH_PORT -m recent --update --seconds 60 --hitcount 4 --name SSH -j LOG --log-prefix "SSH_BRUTE_FORCE: "
$IPT -A TCP_CHAIN -p tcp --dport $SSH_PORT -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP
$IPT -A TCP_CHAIN -p tcp --dport $SSH_PORT -j ACCEPT

# WEB (HTTP/HTTPS)
$IPT -A TCP_CHAIN -p tcp -m multiport --dports $WEB_PORTS -j ACCEPT

# POSTA (collegamento alla catena di sicurezza avanzata)
$IPT -A TCP_CHAIN -p tcp -m multiport --dports $MAIL_PORTS -j MAIL_SECURITY_CHAIN


# --- 6. CATENA DI SICUREZZA AVANZATA PER LA POSTA ---

# Mitigazione Flood/Scan (blocca chi fa più di 5 connessioni in 60s)
$IPT -A MAIL_SECURITY_CHAIN -m recent --set --name MAIL_SCANNER
$IPT -A MAIL_SECURITY_CHAIN -m recent --update --seconds 60 --hitcount 5 --name MAIL_SCANNER -j LOG --log-prefix "MAIL_SCANNER_DROP: "
$IPT -A MAIL_SECURITY_CHAIN -m recent --update --seconds 60 --hitcount 5 --name MAIL_SCANNER -j DROP

# Limita connessioni simultanee (massimo 20 per IP)
$IPT -A MAIL_SECURITY_CHAIN -p tcp -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

# Se tutti i controlli passano, accetta la connessione
$IPT -A MAIL_SECURITY_CHAIN -j ACCEPT


# --- 7. REGOLE IN USCITA (OUTPUT) ---
# Permetti al server di iniziare connessioni per scopi specifici

# DNS
$IPT -A OUTPUT -p udp --dport 53 -j ACCEPT
$IPT -A OUTPUT -p tcp --dport 53 -j ACCEPT

# HTTP/HTTPS (per aggiornamenti, ecc.)
$IPT -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# NTP (Sincronizzazione orario)
$IPT -A OUTPUT -p udp --dport 123 -j ACCEPT

# Invio Email (SMTP)
$IPT -A OUTPUT -p tcp --dport 25 -j ACCEPT


# --- 8. REGOLE FINALI DI LOG E DROP (Opzionale ma consigliato) ---
# Logga i pacchetti che stanno per essere scartati per poterli analizzare
$IPT -A INPUT -j LOG --log-prefix "INPUT_DROPPED: "
$IPT -A OUTPUT -j LOG --log-prefix "OUTPUT_DROPPED: "
$IPT -A FORWARD -j LOG --log-prefix "FORWARD_DROPPED: "

# --- 9. BLOCCO IPv6 (se non lo usi) ---
$IP6T -P INPUT DROP
$IP6T -P FORWARD DROP
$IP6T -P OUTPUT DROP
$IP6T -A INPUT -i lo -j ACCEPT
$IP6T -A OUTPUT -o lo -j ACCEPT
$IP6T -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IP6T -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


echo "Configurazione Firewall completata."
