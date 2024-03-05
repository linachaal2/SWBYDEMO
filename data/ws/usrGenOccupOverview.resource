<resource>
  <id>usrGenOccupOverview</id>
  <name>General Occupation Overview</name>
  <description>General Occupation Overview</description>
  <properties>
    <property name="lpns_received" type="int" description="LPN received"/>
    <property name="lpns_stored_wrong" type="int" description="LPN in process"/>
	<property name="total_available" type="int" description="Total locations" />
    <property name="occupied" type="int" description="Occupied locations"/>
	<property name="lpns_stored" type="int" description="LPN stored"/>
	<property name="free" type="int" description="Locations available"/>
	<property name="percentage_free" type="int" description="% Available"/>
	<property name="critical" type="string" description="Indicator"/>	
	<property name="wh_id" type="string" description="Warehouse ID"/>	 
	<property name="zone" type="string" description="Storage Zone"/>	 
  </properties>
<actions>
	<action type= "list" ref="usrListGenOccupOverview"/>
</actions>
</resource>