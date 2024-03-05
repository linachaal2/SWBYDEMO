<resource>
  <id>usrListToPickSummary</id>
  <name>Tasks to pick per zone summary</name>
  <description>Tasks to pick per zone summary</description>
  <properties>
  <property name= "pck_zone_id" type="int"/>
  <property name= "pck_zone_cod" type="string" pk="true"/>
  <property name= "zone_description" type="string"/>
  <property name= "to_pick" type="int"/>
  </properties>
<actions>
	<action type= "list" ref="usrListToPickSummary"/>
</actions>
</resource>