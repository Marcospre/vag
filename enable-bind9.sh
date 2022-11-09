
DNSIP=$1
ZONA=$2
apt-get update
apt-get install -y bind9 bind9utils bind9-doc
 
cat <<EOF >/etc/bind/named.conf.options
acl "allowed" {
   192.168.1.0/24;
};

options {
    directory "/var/cache/bind";
    dnssec-validation auto;

    listen-on-v6 { any; };
    forwarders { 1.1.1.1;  1.0.0.1;  };
};
EOF

cat <<EOF >/etc/bind/named.conf.local
zone $ZONA {
        type master;
        file "/var/lib/bind/$ZONA";
        };
zone "1.168.192.in-addr.arpa" {
        type master;
        file "/var/lib/bind/192.168.1.rev";
        };
EOF

cat <<EOF >/var/lib/bind/$ZONA
$TTL 3600
$ZONA.     IN      SOA     ns.$ZONA. root.$ZONA. (
                3            ; serial
                7200         ; refresh after 2 hours
                3600         ; retry after 1 hour
                604800       ; expire after 1 week
                86400 )      ; minimum TTL of 1 day

$ZONA.          IN      NS      ns.$ZONA.
ns.$ZONA.       IN      A       $DNSIP
nginx           IN      A       192.168.1.10
apache1.$ZONA.  IN      A       192.168.1.11
apache2         IN      A       192.168.1.12

; aqui pones los hosts
EOF

cat <<EOF >/var/lib/bind/192.168.1.rev
$ttl 3600
1.168.192.in-addr.arpa.  IN      SOA     ns.$ZONA. root.$ZONA. (
                3            ; serial
                7200         ; refresh after 2 hours
                3600         ; retry after 1 hour
                604800       ; expire after 1 week
                86400 )      ; minimum TTL of 1 day
1.168.192.in-addr.arpa.  IN      NS      ns.$ZONA.
11.1.168.192   IN  PTR     apache1
12.1.168.192   IN  PTR     apache2
10.1.168.192   IN  PTR     nginx


; aqui pones los hosts inversos


EOF

cp /etc/resolv.conf{,.bak}
cat <<EOF >/etc/resolv.conf
nameserver 127.0.0.1
domain $ZONA
EOF

 named-checkconf
 named-checkconf /etc/bind/named.conf.options
 named-checkzone ZONA.COM /var/lib/bind/alula194.local.COM
 named-checkzone 1.168.192.in-addr.arpa /var/lib/bind/aula104.local-rev
 sudo systemctl restart bind9