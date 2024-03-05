<resource>
  <id>usrReceiveOverview</id>
  <name>Received LPN Overview</name>
  <description>Received LPN Overview</description>
  <properties>
    <property name="invtyp" type="string" description="ASN Type"/>
	<property name="lpns_received" type="int" description="LPN received"/>
	<property name="stoloc" type="string" description="Indicator"/>
	<property name="wh_id" type="string" description="Warehouse ID"/>	 
  </properties>
<actions>
	<action type= "list" ref="usrListReceiveOverview"/>
</actions>
</resource>