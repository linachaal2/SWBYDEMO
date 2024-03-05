<resource>
  <id>usrHdrTrackOverview</id>
  <name>Zone Delivery Track Overview</name>
  <description>Zone Delivery Track Overview</description>
  <properties>
	<property name="mov_zone_id" pk="true" type="int" description="Movement Zone ID" />
	<property name="wh_id" type="string" description="Warehouse ID"/>	 
	<property name="description" type="string" description="Movement Zone"/>	 
	<property name="mov_zone_cod" type="string" description="Movement Zone Code"/>	 
    <property name="occupied" type="int" description="Occupied locations"/>
	<property name="min_late_ship_date" type="datetime" description="Minumum Late Ship Date"/>	
  </properties>
<actions>
	<action type= "list" ref="usrListHdrTrackOverview"/>
</actions>
</resource>