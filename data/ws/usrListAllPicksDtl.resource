<resource>
  <id>usrListAllPicksDtl</id>
  <name>All picks detail</name>
  <description>All picks detail</description>
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
    <property name= "total_picked" type="int" alias="total_picked" description="total_picked"/>	
	<property name= "picked_headers" type="int" alias="picked_headers" description="picked_headers"/>	
	<property name= "picked" type="int" alias="picked" description="picked"/>	
	<property name= "picked_pallet_picks" type="int" alias="picked_pallet_picks" description="picked_pallet_picks"/>	
	<property name= "picked_pallet_move" type="int" alias="picked_pallet_move" description="picked_pallet_move"/>	
	<property name= "users" type="int" alias="users" description="users"/>	
	</properties>
<actions>
	<action type= "list" ref="usrListAllPicksDtl"/>
</actions>
</resource>