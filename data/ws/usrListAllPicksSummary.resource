<resource>
  <id>usrListAllPicksSummary</id>
  <name>Open picks per zone</name>
  <description>Open picks per zone</description>
  <properties>
  <property name= "pck_zone_cod" type="string"/>
  <property name= "zone_description" type="string" pk="true"/>
  <property name= "open_picks" type="int"/>
  <property name= "pck_zone_id" type="int"/>
  </properties>
<actions>
	<action type= "list" ref="usrListAllPicksSummary"/>
</actions>
</resource>