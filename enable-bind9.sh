
DNSIP=$1
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
zone "aula104.local" {
        type master;
        file "/var/lib/bind/aula104.local";
        };
zone "1.168.192.in-addr.arpa" {
        type master;
        file "/var/lib/bind/aula104.local-rev";
        };
EOF

cat <<EOF >/var/lib/bind/aula104.local
$TTL 3600
aula104.local.     IN      SOA     ns.aula104.local.root.aula104.local. (
                3            ; serial
                7200         ; refresh after 2 hours
                3600         ; retry after 1 hour
                604800       ; expire after 1 week
                86400 )      ; minimum TTL of 1 day

aula104.local.          IN      NS      ns.aula104.local.
ns.aula104.local.       IN      A       $DNSIP
apache1.aula104.local   IN      A       192.168.1.12
apache2.aula104.local   IN      A       192.168.1.13
nginx.aula104.local     IN      A       192.168.1.14
; aqui pones los hosts
EOF

cat <<EOF >/var/lib/bind/aula104.local-rev
$ttl 3600
1.168.192.in-addr.arpa.  IN      SOA     ns.aula104.local.root.aula104.local. (
                3            ; serial
                7200         ; refresh after 2 hours
                3600         ; retry after 1 hour
                604800       ; expire after 1 week
                86400 )      ; minimum TTL of 1 day
1.168.192.in-addr.arpa.  IN      NS      ns.aula104.local.
12.1.168.192   IN  PTR     apache1.
13.1.168.192   IN  PTR     apache2.
14.1.168.192   IN  PTR     nginx.
15.1.168.192  IN  PTR     ns.

; aqui pones los hosts inversos


EOF

cp /etc/resolv.conf{,.bak}
cat <<EOF >/etc/resolv.conf
nameserver 127.0.0.1
domain aula104.local
EOF

 named-checkconf
 named-checkconf /etc/bind/named.conf.options
 named-checkzone ZONA.COM /var/lib/bind/alula194.local.COM
 named-checkzone 1.168.192.in-addr.arpa /var/lib/bind/aula104.local-rev
# sudo systemctl restart bind9