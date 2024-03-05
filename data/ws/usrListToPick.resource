<resource>
  <id>usrListToPick</id>
  <name>Tasks to pick per zone</name>
  <description>Tasks to pick per zone</description>
  <properties>
  <property name= "time_frame" type="string" alias="time_frame" description="time_frame"/>
	<property name= "pck_zone_id" type="int" alias="pck_zone_id" description="pck_zone_id"/>
	<property name= "pck_zone_cod" type="string" alias="pck_zone_id" description="pck_zone_cod"/>
  <property name= "zone_description" type="string" alias="zone_description" description="zone_description"/>
  <property name= "total_open" type="int" alias="total_open" description="total_open"/>	
	<property name= "open_headers" type="int" alias="open_headers" description="open_headers"/>	
	<property name= "open_picks" type="int" alias="open_picks" description="open_picks"/>	
	<property name= "open_pallet_picks" type="int" alias="open_pallet_picks" description="open_pallet_picks"/>	
	<property name= "open_pallet_move" type="int" alias="open_pallet_move" description="open_pallet_move"/>	
  </properties>
<actions>
	<action type= "list" ref="usrListToPick"/>
</actions>
</resource>