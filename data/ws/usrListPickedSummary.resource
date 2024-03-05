<resource>
  <id>usrListPickedSummary</id>
  <name>Picked tasks per zone summary</name>
  <description>Picked tasks per zone summary</description>
  <properties>
  <property name= "pck_zone_id" type="int"/>
  <property name= "pck_zone_cod" type="string" pk="true"/>
  <property name= "zone_description" type="string"/>
  <property name= "total_picked" type="int"/>
  </properties>
<actions>
	<action type= "list" ref="usrListPickedSummary"/>
</actions>
</resource>