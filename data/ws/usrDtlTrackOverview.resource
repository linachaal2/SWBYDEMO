<resource>
  <id>usrDtlTrackOverview</id>
  <name>Detail Delivery Track Overview</name>
  <description>Detail Delivery Track Overview</description>
  <properties>
	<property name="wh_id" type="string" description="Warehouse ID"/>	 
	<property name="zone" type="string" description="Movement Zone"/>	 
	<property name="area" type="string" description="Area"/>	 
	<property name="mov_zone_id" type="int" description="Movement Zone ID"/>
	<property name="mov_zone_cod" type="string" description="Movement Zone Code"/>	 
	<property name="location" type="string" description="Location"/>	 
	<property name="maximum" type="int" description="Maximum Cap."/>	 
    <property name="occupied" type="int" description="Occupied locations"/>
	<property name="min_late_ship_date" type="datetime" description="Minumum Late Ship Date"/>	
	<property name="destination" type="string" description="Destination"/>	 	
  </properties>
<actions>
	<action type= "list" ref="usrListDtlTrackOverview"/>
</actions>
</resource>