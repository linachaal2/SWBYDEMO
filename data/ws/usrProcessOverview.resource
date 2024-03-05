<resource>
  <id>usrProcessOverview</id>
  <name>In Process LPN Overview</name>
  <description>In Process LPN Overview</description>
  <properties>
    <property name="invtyp" type="string" description="ASN Type"/>
	<property name="lpns_in_process" type="int" description="LPN in process"/>
	<property name="stoloc" type="string" description="Indicator"/>
	<property name="wh_id" type="string" description="Warehouse ID"/>	 
  </properties>
<actions>
	<action type= "list" ref="usrListProcessOverview"/>
</actions>
</resource>