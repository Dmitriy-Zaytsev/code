#!/bin/bash
fun_help () {
:
echo "Укажите индексы портов."
echo "`(basename $0)` \"1 26\" \"10101 10124\" \"10201 10202\" > /tmp/zbx_template_trap.xml"
exit 0
}

[[ "$1" = "-h" ]] || [[ "$#" = "0" ]] && fun_help

GROUP_TEMPLATES=G_import
NAME_TEMPLATES=T_SNMP.Trap

fun_echo_head () {
echo '<?xml version="1.0" encoding="UTF-8"?>
<zabbix_export>
    <version>3.0</version>
    <date>2016-08-24T15:31:38Z</date>
    <groups>
        <group>
            <name>G_Templates</name>
        </group>
    </groups>
    <templates>
        <template>
            <template>'"$NAME_TEMPLATES"'</template>
            <name>T_SNMP.Trap</name>
            <description/>
            <groups>
                <group>
                    <name>'"$GROUP_TEMPLATES"'</name>
                </group>
            </groups>
            <applications/>
            <items>
                <item>
                    <name>I_Trap.All</name>
                    <type>17</type>
                    <snmp_community/>
                    <multiplier>0</multiplier>
                    <snmp_oid/>
                    <key>snmptrap.fallback</key>
                    <delay>0</delay>
                    <history>1</history>
                    <trends>0</trends>
                    <status>0</status>
                    <value_type>2</value_type>
                    <allowed_hosts/>
                    <units/>
                    <delta>0</delta>
                    <snmpv3_contextname/>
                    <snmpv3_securityname/>
                    <snmpv3_securitylevel>0</snmpv3_securitylevel>
                    <snmpv3_authprotocol>0</snmpv3_authprotocol>
                    <snmpv3_authpassphrase/>
                    <snmpv3_privprotocol>0</snmpv3_privprotocol>
                    <snmpv3_privpassphrase/>
                    <formula>1</formula>
                    <delay_flex/>
                    <params/>
                    <ipmi_sensor/>
                    <data_type>0</data_type>
                    <authtype>0</authtype>
                    <username/>
                    <password/>
                    <publickey/>
                    <privatekey/>
                    <port/>
                    <description/>
                    <inventory_link>0</inventory_link>
                    <applications/>
                    <valuemap/>
                    <logtimefmt>hh:mm:ss yyyy/MM/dd</logtimefmt>
                </item>
                <item>
                    <name>I_Trap.LinkDown</name>
                    <type>17</type>
                    <snmp_community/>
                    <multiplier>0</multiplier>
                    <snmp_oid/>
                    <key>snmptrap[linkDown]</key>
                    <delay>0</delay>
                    <history>1</history>
                    <trends>0</trends>
                    <status>0</status>
                    <value_type>2</value_type>
                    <allowed_hosts/>
                    <units/>
                    <delta>0</delta>
                    <snmpv3_contextname/>
                    <snmpv3_securityname/>
                    <snmpv3_securitylevel>0</snmpv3_securitylevel>
                    <snmpv3_authprotocol>0</snmpv3_authprotocol>
                    <snmpv3_authpassphrase/>
                    <snmpv3_privprotocol>0</snmpv3_privprotocol>
                    <snmpv3_privpassphrase/>
                    <formula>1</formula>
                    <delay_flex/>
                    <params/>
                    <ipmi_sensor/>
                    <data_type>0</data_type>
                    <authtype>0</authtype>
                    <username/>
                    <password/>
                    <publickey/>
                    <privatekey/>
                    <port/>
                    <description/>
                    <inventory_link>0</inventory_link>
                    <applications/>
                    <valuemap/>
                    <logtimefmt>hh:mm:ss yyyy/MM/dd</logtimefmt>
                </item>
                <item>
                    <name>I_Trap.LinkUP</name>
                    <type>17</type>
                    <snmp_community/>
                    <multiplier>0</multiplier>
                    <snmp_oid/>
                    <key>snmptrap[linkUp]</key>
                    <delay>0</delay>
                    <history>1</history>
                    <trends>0</trends>
                    <status>0</status>
                    <value_type>2</value_type>
                    <allowed_hosts/>
                    <units/>
                    <delta>0</delta>
                    <snmpv3_contextname/>
                    <snmpv3_securityname/>
                    <snmpv3_securitylevel>0</snmpv3_securitylevel>
                    <snmpv3_authprotocol>0</snmpv3_authprotocol>
                    <snmpv3_authpassphrase/>
                    <snmpv3_privprotocol>0</snmpv3_privprotocol>
                    <snmpv3_privpassphrase/>
                    <formula>1</formula>
                    <delay_flex/>
                    <params/>
                    <ipmi_sensor/>
                    <data_type>0</data_type>
                    <authtype>0</authtype>
                    <username/>
                    <password/>
                    <publickey/>
                    <privatekey/>
                    <port/>
                    <description/>
                    <inventory_link>0</inventory_link>
                    <applications/>
                    <valuemap/>
                    <logtimefmt>hh:mm:ss yyyy/MM/dd</logtimefmt>
                </item>
            </items>
            <discovery_rules/>
            <macros/>
            <templates/>
            <screens/>
        </template>
    </templates>
    <triggers>'
}

fun_echo_end () {
echo '    </triggers>
</zabbix_export>'
}

fun_echo_trigger () {
echo '<trigger>
            <expression>({TRIGGER.VALUE}=0 and ({T_SNMP.Trap:snmptrap[linkDown].str("ifIndex.'"$port"' ")}=1 and {T_SNMP.Trap:snmptrap[linkDown].nodata(1)}&lt;&gt;1))</expression>
            <name>t_Port.Down.'"$port"'_{HOST.NAME}/{HOST.IP}</name>
            <url/>
            <status>0</status>
            <priority>3</priority>
            <description/>
            <type>0</type>
            <dependencies/>
        </trigger>
        <trigger>
            <expression>({TRIGGER.VALUE}=0 and ({T_SNMP.Trap:snmptrap[linkUp].str("ifIndex.'"$port"' ")}=1 and {T_SNMP.Trap:snmptrap[linkUp].nodata(1)}&lt;&gt;1))</expression>
            <name>t_Port.Up.'"$port"'_{HOST.NAME}/{HOST.IP}</name>
            <url/>
            <status>0</status>
            <priority>3</priority>
            <description/>
            <type>0</type>
            <dependencies/>
        </trigger>'
}


exec 4>&1
exec 1>&2
echo "
name:templates$NAME_TEMPLATES
group templates:$GROUP_TEMPLATES
"

read
exec 1>&4


fun_echo_head
 for numvar in  `(seq 1 $#)`
  do
   eval VAR=\$"${numvar}"
   for port in `(seq $VAR)`
    do
     fun_echo_trigger
    done
  done
fun_echo_end
