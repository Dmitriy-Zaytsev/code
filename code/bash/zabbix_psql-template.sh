#!/bin/bash
#Для генерации item,graph на базу postgresql по таблицам через odbc(вид item).
filetable=/tmp/table.txt
fileitem=/tmp/tem.temp
filegrap=/tmp/tem2.temp
fileout=/tmp/template.xml
rm -rf $fileitem $filegrap $fileout

fun_head () {
echo "
<zabbix_export>
    <version>3.0</version>
    <date>2016-07-22T10:37:18Z</date>
    <groups>
        <group>
            <name>G_template</name>
        </group>
    </groups>
    <templates>
        <template>
            <template>T_Linux_DB-Zabbix</template>
            <name>T_Linux_DB-Zabbix</name>
            <description/>
            <groups>
                <group>
                    <name>G_template</name>
                </group>
            </groups>
            <applications/>
            <items>"
}

fun_separ () {
echo "
 </items>
            <discovery_rules/>
            <macros/>
            <templates/>
            <screens/>
        </template>
    </templates>
    <graphs>
        <graph>
            <name>g_linuxDB</name>
            <width>900</width>
            <height>200</height>
            <yaxismin>0.0000</yaxismin>
            <yaxismax>100.0000</yaxismax>
            <show_work_period>1</show_work_period>
            <show_triggers>1</show_triggers>
            <type>0</type>
            <show_legend>1</show_legend>
            <show_3d>0</show_3d>
            <percent_left>0.0000</percent_left>
            <percent_right>0.0000</percent_right>
            <ymin_type_1>0</ymin_type_1>
            <ymax_type_1>0</ymax_type_1>
            <ymin_item_1>0</ymin_item_1>
            <ymax_item_1>0</ymax_item_1>
            <graph_items>"

}

fun_end () {
echo "
            </graph_items>
        </graph>
    </graphs>
</zabbix_export>"
}

fun_itemDB () {
echo "
  <item>
                    <name>I_db_size</name>
                    <type>11</type>
                    <snmp_community/>
                    <multiplier>0</multiplier>
                    <snmp_oid/>
                    <key>db.odbc.select[sizedb,odbc_pgdb]</key>
                    <delay>15</delay>
                    <history>3</history>
                    <trends>60</trends>
                    <status>0</status>
                    <value_type>3</value_type>
                    <allowed_hosts/>
                    <units>B</units>
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
                    <params>SELECT pg_database_size('zabbix')</params>
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
                    <logtimefmt/>
                </item>"
}

fun_item () {
echo "
<item>
                    <name>I_db_table.count_$table</name>
                    <type>11</type>
                    <snmp_community/>
                    <multiplier>0</multiplier>
                    <snmp_oid/>
                    <key>db.odbc.select[count.table_$table,odbc_pgdb]</key>
                    <delay>15</delay>
                    <history>3</history>
                    <trends>60</trends>
                    <status>0</status>
                    <value_type>3</value_type>
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
                    <params>SELECT COUNT(*) FROM $table</params>
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
                    <logtimefmt/>
                </item>
                <item>
                    <name>I_db_table.size_$table</name>
                    <type>11</type>
                    <snmp_community/>
                    <multiplier>0</multiplier>
                    <snmp_oid/>
                    <key>db.odbc.select[size.table_$table,odbc_pgdb]</key>
                    <delay>15</delay>
                    <history>3</history>
                    <trends>60</trends>
                    <status>0</status>
                    <value_type>3</value_type>
                    <allowed_hosts/>
                    <units>B</units>
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
                    <params>SELECT pg_total_relation_size('$table')</params>
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
                    <logtimefmt/>
                </item>"
}


fun_graphDB () {
echo "
 <graph_item>
                    <sortorder>0</sortorder>
                    <drawtype>1</drawtype>
                    <color>33FF33</color>
                    <yaxisside>0</yaxisside>
                    <calc_fnc>2</calc_fnc>
                    <type>0</type>
                    <item>
                        <host>T_Linux_DB-Zabbix</host>
                        <key>db.odbc.select[sizedb,odbc_pgdb]</key>
                    </item>
                </graph_item>"
}

fun_graph () {
echo "
 <graph_item>
                    <sortorder>1</sortorder>
                    <drawtype>0</drawtype>
                    <color>$color</color>
                    <yaxisside>0</yaxisside>
                    <calc_fnc>2</calc_fnc>
                    <type>0</type>
                    <item>
                        <host>T_Linux_DB-Zabbix</host>
                        <key>db.odbc.select[size.table_$table,odbc_pgdb]</key>
                    </item>
                </graph_item>
                <graph_item>
                    <sortorder>2</sortorder>
                    <drawtype>4</drawtype>
                    <color>$color</color>
                    <yaxisside>1</yaxisside>
                    <calc_fnc>2</calc_fnc>
                    <type>0</type>
                    <item>
                        <host>T_Linux_DB-Zabbix</host>
                        <key>db.odbc.select[count.table_$table,odbc_pgdb]</key>
                    </item>
                </graph_item>"
}


while read table
do
color=`(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 6 | head -n 1)`
fun_item >> $fileitem
fun_graph >> $filegrap
done < $filetable

(fun_head;fun_itemDB;cat $fileitem;fun_separ;fun_graphDB;cat $filegrap;fun_end)  | tee $fileout
