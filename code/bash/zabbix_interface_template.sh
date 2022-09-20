#!/bin/bash
#Таже версия только есть возможность через macros-ы поменять значение триггера
#на загрузку интерфейса,и snmp_community.
#+HELP
name_script=`(basename $0)`
fun_help () {
echo "HELP
-h - help.
-U - unicast pkts.
-B - broadcast pkts.
-M - multicast pkts.
-E - добавить item-ы на DiscardsOUT и ErrorIN.
-b 1 - номер первого интерфейса.
-e 24 - номер последнего интерфейса.
-c {g|t|G|T} - указать что это порты ciso gigabit(g)/ciso tengigabit(t)/gigabit(G)/tengigabit(T)/fastehernet(F) (у cisco различия в oid индексах портов)
пример:10106-6port1G, 10201-1port10G).
-t 50 - добавить триггеры,и сработать если больше 50 Mbit.
-g - добавить графики по интерфейсам(Octet,UniC,BroadC,MultC).
-G - в какую группу будет входить шаблон.
-T - название шаблона.
-s - состояние интерфейса up/down по трафику(не по трапам).

<<EXAMPLE>>
Для того что бы определить snmpindex интерфейсов.
snmpwalk -c ghbitktw -v2c 192.168.33.162 ifDescr


Cisco ME-3600X-24FS-M:
$name_script -U -B -M -E -b 1 -e 24 -t 700 -g -c g -G G_import -T T_interface_ME3600 > /tmp/ME3600x_1-24-1g.xml
$name_script -U -B -M -E -b 1 -e 2 -t 7000 -g -c t -G G_import -T T_interface_ME3600 > /tmp/ME3600x_1-2-10g.xml

Cisco WS-C4600X-16x:
!!! С4600x - НЕ использует snmp индекса 101-1G 102-10G.
$name_script -U -B -M -E -b 1 -e 1 -t 70 -g -c F -G G_import -T T_interface_C4500X-16 > /tmp/C4500X-16x_1-100m.xml
$name_script -U -B -M -E -b 2 -e 17 -t 8500 -c T -g -G G_import -T T_interface_C4500X-16 > /tmp/C4500X-16x_2-17-10g.xml

Cisco WS-C2950T-24:
$name_script -U -B -M -E -b 1 -e 24 -t 85 -c F -g -G G_import -T T_interface_C2950 > /tmp/C2950_1-24_100m.xml
$name_script -U -B -M -E -b 25 -e 26 -t 850 -c G -g -G G_import -T T_interface_C2950 > /tmp/C2950_25-26_1g.xml


Edge-Core ES4626-SFP:
$name_script -U -B -M -E -b 1 -e 24 -t 850 -c G -g -G G_import -T T_interface_ES4626 > /tmp/ES4626_1-24_1g.xml
$name_script -U -B -M -E -b 25 -e 26 -t 8500 -c T -g -G G_import -T T_interface_ES4626 > /tmp/ES4626_25-26_10g.xml

Edge-Core ES3528:
$name_script -U -B -M -E -b 1 -e 24 -t 85 -c F -g -G G_import -T T_interface_ES3528 > /tmp/ES3528_1-24_100m.xml
$name_script -U -B -M -E -b 25 -e 28 -t 850 -c G -g -G G_import -T T_interface_ES3528 > /tmp/ES3528_25-28_1g.xml



Выяснить нумерацию портов.
snmpwalk -c kp2x45dv8v -v 2c 172.21.64.9 ifDescr
snmpwalk -c kp2x45dv8v -v 2c 172.21.64.9 .1.3.6.1.2.1.2.2.1.2
Все возможная информация по портам.
snmpwalk -v 1 -c ghbitktw 172.19.32.2 iso.org.dod.internet.mgmt.mib-2.interfaces 2>/dev/null

!!! При слиянии шаблонов заменяются macros-ы, нужно вписывать руками, или в ручным добавлением в xml
macroso-в в шаблон который будет загружен последним с первого xml файла(шаблона).
"
exit
}
#-HELP

[ "$#" = "0" ] && fun_help
while getopts "hUBMb:e:c:t:gEG:T:s" Opt
 do
  case $Opt in
   h ) fun_help;;
   U ) unicast=enable;;
   B ) broadcast=enable;;
   M ) multicast=enable;;
   b ) interface_begin=$OPTARG;;
   e ) interface_end=$OPTARG;;
   c ) [ "$OPTARG" = "F" ] && view_interface=fastethernet ;\
[ "$OPTARG" = "g" ] && view_interface=ciscogigabit;NAME_LIMIT_UTILIZ="LIMIT.GIG_";\
[ "$OPTARG" = "t" ] && view_interface=ciscoten;NAME_LIMIT_UTILIZ="LIMIT.TEN_";\
[ "$OPTARG" = "G" ] && view_interface=gigabit;NAME_LIMIT_UTILIZ="LIMIT.GIG_";\
[ "$OPTARG" = "T" ] && view_interface=ten;NAME_LIMIT_UTILIZ="LIMIT.TEN_";;
   t ) limit_load=$OPTARG; trigger=enable;;
   g ) graph=enable;;
   E ) error=enable;;
   G ) GROUP_TEMPLATE=$OPTARG;;
   T ) TEMPLATE=$OPTARG;;
   s ) state_interface=enable;;
  esac
 done
exec 4>&1
exec 1>&2

#----------GENERAL-------------
GROUP_TEMPLATE=${GROUP_TEMPLATE:-G_import} #Группа в которой будет шаблон.
TEMPLATE=${TEMPLATE:-T_switch} #Сам шаблон.
#------------OPTION------------
unicast=${unicast:-disable}
broadcast=${broadcast:-disable}
multicast=${multicast:-disable}
error=${error:-disable}
interface_begin=${interface_begin:-1}
interface_end=${interface_end:-24}
ciscogigabit=${ciscogigabit:-disable}
ciscoten=${ciscoten:-disable}
trigger=${trigger:-disable};limit_load=${limit_load:-100}
graph=${graph:-disable}
state_interface=${state_interface:-disable}
view_interface=${view_interface:-fastehernet}
NAME_LIMIT_UTILIZ=${NAME_LIMIT_UTILIZ:-LIMIT.FAST_} #Часть имени для макроса для лимита на загрузку интерфейса.
SLOT=0 #F0/1 F1/1 G0/15
#++++++++++++++++OID SNMP++++++++++++++++++++++++
oid_ifInOctets=".1.3.6.1.2.1.2.2.1.10."
oid_ifOutOctets=".1.3.6.1.2.1.2.2.1.16."
#--
oid_ifInBroadcastPkts=".1.3.6.1.2.1.31.1.1.1.3."
oid_ifOutBroadcastPkts=".1.3.6.1.2.1.31.1.1.1.5."
#--
oid_ifInUcastPkts=".1.3.6.1.2.1.2.2.1.11."
oid_ifOutUcastPkts=".1.3.6.1.2.1.2.2.1.17."
#--
oid_ifInMulticastPkts=".1.3.6.1.2.1.31.1.1.1.2."
oid_ifOutMulticastPkts=".1.3.6.1.2.1.31.1.1.1.4."
#--
oid_ifOutDiscards=".1.3.6.1.2.1.2.2.1.19."
oid_ifInErrors=".1.3.6.1.2.1.2.2.1.14."
#+++++++++++++++++++++++++++++++++++++++++++++++++
#-----------ITEM---------------
NAME_SNMP_COMMUNITY='{$SNMP.COMM}' #snmp community для item(элемента),{$SNMP.COMM}-макрос.
SNMP_COMMUNITY_MACRO='kp2x45dv8v' #значение для описание макроса в шаблоне.
DELAY=''
DELAY_A=6 #Для остальных items bps/pps.
DELAY_E=600 #Для Discard/Errors
HISTORY_A=1
HISTORY_E=1 #Для Discard/Errors
TRENDS_A=60
TRENDS_E=0 #Для Discard/Errors
MULTIPLIER=''
UNITS=''
FORMULA=''
ITEM_NAME=''
KEY=''
#----------TRIGGER-------------
EXPRESSION=''
LIMIT_LOAD_MACRO=$((limit_load * 1024 * 1024)) #значение для описание макроса в шаблоне.
NAME_LIMIT_UTILIZ="LIMIT.UTILIZ_" #Название макроса.
TRIGGER_NAME=''
PRIORITY=2
PACK_DISCARDS=20 #На сколько должно быть значение больше предидущего что бы тригер discards сработал.
PACK_ERRORS=20
#-----------GRAPH--------------
COLOR='';DRAW='';Y='' #Y - положение оси Y.
O_IN_COLOR='66FF66';O_OUT_COLOR='FF6666';O_DRAW=5
U_IN_COLOR='00AA00';U_OUT_COLOR='AA0000';U_DRAW=4
B_IN_COLOR='005500';B_OUT_COLOR='550000';B_DRAW=0
M_IN_COLOR='DDDD00';M_OUT_COLOR='EE00EE';M_DRAW=0
GRAPH_NAME=''
SORTORDER='' #Кто будет выше в графике.

#Переменные для item-ов по bps(Octet) и pps(Broadcast,Multicast,Unicast).
fun_var_item_bps () {
MULTIPLIER=1
UNITS=bps
FORMULA=8
DELAY=$DELAY_A
HISTORY=$HISTORY_A
TRENDS=$TRENDS_A
}
fun_var_item_pps () {
MULTIPLIER=1
UNITS=pps
FORMULA=1
DELAY=$DELAY_A
HISTORY=$HISTORY_A
TRENDS=$TRENDS_A
}
fun_var_item_error () {
MULTIPLIER=0
UNITS='';
FORMULA=1
DELAY=$DELAY_E
HISTORY=$HISTORY_E
TRENDS=$TRENDS_E
}




echo "
unicast: $unicast
broadcast: $broadcast
multicast: $multicast
error: $error
interface_begin: $interface_begin interface_end: $interface_end
ciscogigabit: $ciscogigabit ciscoten: $ciscoten
trigger: $trigger limit_load: $limit_load
graph: $graph
group_template: $GROUP_TEMPLATE
template: $TEMPLATE
state_interface: $state_interface
view_interface: $view_interface
"
read -n1 -p 'Продолжить? (Y/n)' key
[ "$key" = "n" -o "$key" = "N" ] && exit
exec 1>&4


fun_view_interface () {
unset index_oid INT INT_K INT_M
if [ "$view_interface" = "ciscogigabit" ]
    then
      index_oid=$interface
      [ "`(echo $interface | wc -m)`" = "2" ] && index_oid=0$interface
      index_oid=101$index_oid
      #Т.е за место 13-SNMPindex, получим 10113, 5-10105.

      INT=G$SLOT/$interface
      INT_K=G$SLOT-$interface #Для ключа item-а нет возможности применить /.
      INT_M=G$SLOT.$interface #Для макросов нельзя применять / и -.
  fi
  if [ "$view_interface" = "ciscoten" ]
    then
      index_oid=$interface
      [ "`(echo $interface | wc -m)`" = "2" ] && index_oid=0$interface
      index_oid=102$index_oid
      INT=T$SLOT/$interface
      INT_K=T$SLOT-$interface
      INT_M=T$SLOT.$interface
  fi
 
  if [ "$view_interface" = "gigabit" ]
    then
      index_oid=$interface
      INT=G$SLOT/$interface
      INT_K=G$SLOT-$interface
      INT_M=G$SLOT.$interface
  fi
  if [ "$view_interface" = "ten" ]
    then
      index_oid=$interface
      INT=T$SLOT/$interface
      INT_K=T$SLOT-$interface
      INT_M=T$SLOT.$interface
  fi
  if [ "$view_interface" = "fastethernet" ]
    then
      index_oid=$interface
      INT=F$SLOT/$interface
      INT_K=F$SLOT-$interface
      INT_M=F$SLOT.$interface
  fi

}


#--XML GROUP,TEMPLATE
fun_xml_head () {
echo '<zabbix_export>
  <version>3.0</version>
    <groups>
        <group>
            <name>'"$GROUP_TEMPLATE"'</name>
        </group>
    </groups>
    <templates>
        <template>
            <template>'"$TEMPLATE"'</template>
            <name>'"$TEMPLATE"'</name>
            <description>generated script '"$0"'</description>
            <groups>
                <group>
                    <name>'"$GROUP_TEMPLATE"'</name>
                </group>
            </groups>
            <macros>
                <macro>
                    <macro>'"$NAME_SNMP_COMMUNITY"'</macro>
                    <value>'"$SNMP_COMMUNITY_MACRO"'</value>
                </macro>'
}


fun_xml_macro_load () {
echo '                <macro>
                    <macro>{$'"$NAME_LIMIT_UTILIZ$INT_M"'}</macro>
                    <value>'"$LIMIT_LOAD_MACRO"'</value>
                </macro>'
}

fun_xml_macro_error () {
echo '                <macro>
                    <macro>{$PACK.DISCARD_'"$INT_M"'}</macro>
                    <value>'"$PACK_DISCARDS"'</value>
                </macro>'
}

fun_xml_macro_discard () {
echo '                <macro>
                    <macro>{$PACK.ERROR_'"$INT_M"}'</macro>
                    <value>'"$PACK_ERRORS"'</value>
                </macro>'
}



fun_xml_head_macro_end () {
echo '            </macros>'

}



fun_xml_end () {
echo '</zabbix_export>'
}


#--XML ITEM
fun_xml_item_start () {
echo '            <items>'
}
fun_xml_item () {
echo '                <item>
                    <name>'"$ITEM_NAME"'</name>
                    <type>4</type>
                    <snmp_community>'"$NAME_SNMP_COMMUNITY"'</snmp_community>
                    <multiplier>'"$MULTIPLIER"'</multiplier>
                    <snmp_oid>'"$OID"'</snmp_oid>
                    <key>'"$KEY"'</key>
                    <delay>'"$DELAY"'</delay>
                    <history>'"$HISTORY"'</history>
                    <trends>'"$TRENDS"'</trends>
                    <status>0</status>
                    <value_type>3</value_type>
                    <allowed_hosts/>
                    <units>'"$UNITS"'</units>
                    <delta>'"$DELTA"'</delta>
                    <snmpv3_contextname/>
                    <snmpv3_securityname/>
                    <snmpv3_securitylevel>0</snmpv3_securitylevel>
                    <snmpv3_authprotocol>0</snmpv3_authprotocol>
                    <snmpv3_authpassphrase/>
                    <snmpv3_privprotocol>0</snmpv3_privprotocol>
                    <snmpv3_privpassphrase/>
                    <formula>'"$FORMULA"'</formula>
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
                    <logtimefmt/>
                </item>'
}
fun_xml_item_stop () {
echo '              </items>
           </template>
       </templates>'
}



#+XML.group,template,ITEM.
fun_xml_head
for interface in `(seq "$interface_begin" "$interface_end")`
 do
   fun_view_interface
   fun_xml_macro_load
   fun_xml_macro_error
   fun_xml_macro_discard
 done
fun_xml_head_macro_end
fun_xml_item_start
for interface in `(seq "$interface_begin" "$interface_end")`
 do

    fun_view_interface


   #+Octet
   fun_var_item_bps
   ITEM_NAME=I_If.In.Octets.$INT
   KEY=If.In.Octets.$INT_K
   OID=$oid_ifInOctets$index_oid
   DELTA=1
   fun_xml_item

   ITEM_NAME=I_If.Out.Octets.$INT
   KEY=If.Out.Octets.$INT_K
   OID=$oid_ifOutOctets$index_oid
   fun_xml_item
   #-Octet

   #+Unicast
   if [ "$unicast" = "enable" ]
     then
      fun_var_item_pps
      ITEM_NAME=I_If.In.Ucast.$INT
      KEY=If.In.Ucast.$INT_K
      OID=$oid_ifInUcastPkts$index_oid
      DELTA=1
      fun_xml_item

      ITEM_NAME=I_If.Out.Ucast.$INT
      KEY=If.Out.Ucast.$INT_K
      OID=$oid_ifOutUcastPkts$index_oid
      fun_xml_item
   fi
   #-Unicast

   #+Broadcast
   if [ "$broadcast" = "enable" ]
     then
      fun_var_item_pps
      ITEM_NAME=I_If.In.Broadcast.$INT
      KEY=If.In.Broadcast.$INT_K
      OID=$oid_ifInBroadcastPkts$index_oid
      DELTA=1
      fun_xml_item

      ITEM_NAME=I_If.Out.Broadcast.$INT
      KEY=If.Out.Broadcast.$INT_K
      OID=$oid_ifOutBroadcastPkts$index_oid
      fun_xml_item
   fi
   #-Broadcast

   #+Multicast
   if [ "$multicast" = "enable" ]
     then
      fun_var_item_pps
      ITEM_NAME=I_If.In.Multicast.$INT
      KEY=If.In.Multicast.$INT_K
      OID=$oid_ifInMulticastPkts$index_oid
      DELTA=1
      fun_xml_item

      ITEM_NAME=I_If.Out.Multicast.$INT
      KEY=If.Out.Multicast.$INT_K
      OID=$oid_ifOutMulticastPkts$index_oid
      fun_xml_item
   fi
   #-Multicast

   #+Error/Discard
   if [ "$error" = "enable" ]
     then
      fun_var_item_error
      ITEM_NAME=I_If.In.Errors.$INT
      KEY=If.In.Errors.$INT_K
      OID=$oid_ifInErrors$index_oid
      DELTA=0
      fun_xml_item

      ITEM_NAME=I_If.Out.Discards.$INT
      KEY=If.Out.Discards.$INT_K
      OID=$oid_ifOutDiscards$index_oid
      fun_xml_item
   fi
   #-Error/Discard
 done
fun_xml_item_stop
#-XML.group,template,ITEM.


#--XML.TRIGGER
fun_xml_trigger_start () {
echo '    <triggers>'
}
fun_xml_trigger_stop () {
echo '    </triggers>'
}

fun_xml_trigger () {
echo ' <trigger>
            <expression>'"$EXPRESSION"'</expression>
            <name>'"$TRIGGER_NAME"'</name>
            <url/>
            <status>0</status>
            <priority>'"$PRIORITY"'</priority>
            <description/>
            <type>0</type>
            <dependencies/>
        </trigger>'

}


#+XML.add TRIGGER.
if [[ "$trigger" = "enable" ]]
  then
   fun_xml_trigger_start
   for interface in `(seq "$interface_begin" "$interface_end")`
     do
      fun_view_interface

      #OCTET
      PRIORITY=4
      #ITEM_NAME=I_If.In.Octets.$INT
      KEY=If.In.Octets.$INT_K
      TRIGGER_NAME="t_If.High.Load.In."$INT"_{HOST.NAME}/{HOST.IP}_{ITEM.VALUE}>\$1bps"
      EXPRESSION="{$TEMPLATE:$KEY.last(#1)}&gt;{\$$NAME_LIMIT_UTILIZ$INT_M}"
      fun_xml_trigger

      #ITEM_NAME=I_If.Out.Octets.$INT
      KEY=If.Out.Octets.$INT_K
      TRIGGER_NAME="t_If.High.Load.Out."$INT"_{HOST.NAME}/{HOST.IP}_{ITEM.VALUE}>\$1bps"
      EXPRESSION="{$TEMPLATE:$KEY.last(#1)}&gt;{\$$NAME_LIMIT_UTILIZ$INT_M}"
      fun_xml_trigger

       #Error/Discard
      if [ "$error" = "enable" ]
      then
        PRIORITY=2
        #ITEM_NAME=I_If.In.Errors.$INT
        KEY=If.In.Errors.$INT_K
        TRIGGER_NAME="t_If.Error.In."$INT"_{HOST.NAME}/{HOST.IP}_{ITEM.LASTVALUE}-->{ITEM.VALUE}"
        EXPRESSION="{$TEMPLATE:$KEY.last(#1)}-{$TEMPLATE:$KEY.last(#2)}&gt;{\$PACK.ERROR_$INT_M}"
        fun_xml_trigger

        #ITEM_NAME=I_If.Out.Discards.$INT
        KEY=If.Out.Discards.$INT_K
        TRIGGER_NAME="t_If.Discard.Out."$INT"_{HOST.NAME}/{HOST.IP}_{ITEM.LASTVALUE}-->{ITEM.VALUE}"
	EXPRESSION="{$TEMPLATE:$KEY.last(#1)}-{$TEMPLATE:$KEY.last(#2)}&gt;{\$PACK.DISCARD_$INT_M}"
        fun_xml_trigger
       fi

        #UP/Down port
        if [ "$state_interface" = "enable" ]
          then
	    PRIORITY=4
            KEY1=If.In.Octets.$INT_K
	    KEY2=If.Out.Octets.$INT_K

	    TRIGGER_NAME="t_If.Down."$INT"_{HOST.NAME}/{HOST.IP}"
            EXPRESSION="({TRIGGER.VALUE}=0 and {$TEMPLATE:$KEY1.last(#1)}=0 and {$TEMPLATE:$KEY2.last(#1)}=0 and {$TEMPLATE:$KEY1.last(#2)}&gt;=0 and {$TEMPLATE:$KEY2.last(#2)}&gt;0)"
            fun_xml_trigger

            TRIGGER_NAME="t_If.Up."$INT"_{HOST.NAME}/{HOST.IP}"
            EXPRESSION="({TRIGGER.VALUE}=0 and {$TEMPLATE:$KEY1.last(#1)}&gt;=0 and {$TEMPLATE:$KEY2.last(#1)}&gt;0 and {$TEMPLATE:$KEY1.last(#2)}=0 and {$TEMPLATE:$KEY2.last(#2)}=0)"
            fun_xml_trigger
	fi
      done

   fun_xml_trigger_stop
fi
#-XML.add TRIGGER.


#--XML.GRAPH
fun_xml_graph_head () {
echo '        <graph>
            <name>'"$GRAPH_NAME"'</name>
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
            <graph_items>'
}

fun_xml_graph () {
echo '                <graph_item>
                    <sortorder>'"$SORTORDER"'</sortorder>
                    <drawtype>'"$DRAW"'</drawtype>
                    <color>'"$COLOR"'</color>
                    <yaxisside>'"$Y"'</yaxisside>
                    <calc_fnc>2</calc_fnc>
                    <type>0</type>
                    <item>
                        <host>'"$TEMPLATE"'</host>
                        <key>'"$KEY"'</key>
                    </item>
                </graph_item>'
}

fun_xml_graph_separate () {
#Один график закончился закрываем шапку fun_xml_graph_start
echo '            </graph_items>
        </graph>'
}

fun_xml_graph_start () {
echo '    <graphs>'
}
fun_xml_graph_stop () {
echo '    </graphs>'
}


#+XML.add GRAPH.
if [[ "$graph" = "enable" ]]
  then
fun_xml_graph_start
for interface in `(seq "$interface_begin" "$interface_end")`
 do

   fun_view_interface

   GRAPH_NAME=g_If.$INT
   fun_xml_graph_head

   #+Octet
   KEY=If.In.Octets.$INT_K
   DRAW="$O_DRAW"
   COLOR="$O_IN_COLOR";SORTORDER=0 #Приоритет на графике.
   Y=0 #Расположение оси Y с левой стороны.
   fun_xml_graph

   KEY=If.Out.Octets.$INT_K
   DRAW="$O_DRAW"
   COLOR="$O_OUT_COLOR";SORTORDER=1
   Y=0 #Расположение оси Y с левой стороны.
   fun_xml_graph
   #-Octet

   #+Unicast
   if [ "$unicast" = "enable" ]
     then
      KEY=If.In.Ucast.$INT_K
      DRAW="$U_DRAW"
      COLOR="$U_IN_COLOR";SORTORDER=2
      Y=1 #Расположение оси Y с правой стороны.
      fun_xml_graph

      KEY=If.Out.Ucast.$INT_K
      DRAW="$U_DRAW"
      COLOR="$U_OUT_COLOR";SORTORDER=3
      fun_xml_graph
   fi
   #-Unicast

   #+Broadcast
   if [ "$broadcast" = "enable" ]
     then
      KEY=If.In.Broadcast.$INT_K
      DRAW="$B_DRAW"
      COLOR="$B_IN_COLOR";SORTORDER=4
      Y=1
      fun_xml_graph

      KEY=If.Out.Broadcast.$INT_K
      DRAW="$B_DRAW"
      COLOR="$B_OUT_COLOR";SORTORDER=5
      fun_xml_graph
   fi
   #-Broadcast

   #+Multicast
   if [ "$multicast" = "enable" ]
     then
      KEY=If.In.Multicast.$INT_K
      DRAW="$M_DRAW"
      COLOR="$M_IN_COLOR";SORTORDER=6
      Y=1
      fun_xml_graph

      KEY=If.Out.Multicast.$INT_K
      DRAW="$M_DRAW"
      COLOR="$M_OUT_COLOR";SORTORDER=7
      fun_xml_graph
   fi
   #-Multicast
   fun_xml_graph_separate
 done
fun_xml_graph_stop
fi


fun_xml_end
#-XML.add GRAPH.
